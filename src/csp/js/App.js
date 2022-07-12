import {Document} from './iris/Document.js'
import {marked} from './lib/marked/marked.js'
import {System} from "./iris/System.js"
import {mustache} from "./lib/moustache/moustache.js"
import Mermaid from "./lib/mermaid/mermaid.js"
import {Chart, registerables} from './lib/chartjs/chart.esm.js';

Chart.register(...registerables);

export class App {

    constructor() {
        this.editorContentEl = document.getElementById('editor-content');
        this.previewContentEl = document.getElementById('preview-content-inner')
        this.docName = new URLSearchParams(window.location.search).get('doc');
        this.content = '';
        this.data = {};
        this.busy = false;  //used to debounce server actions and reduce IO activity
        this.id = 0;
        this.ns = 'IWS'  //TODO, remove this hardcoding !!
        this.nextSectionToRender = 0;
        this.sections = [];
        this.queryBusy = false;
        this.openDocument();
    }

    openDocument() {
        Document.open(this.ns,this.docName).then( document => {
            this.document = document
            let cdataSplit = document.content.split('<![CDATA[')
            this.classLeftPart = cdataSplit[0] + '<![CDATA[';
            cdataSplit = cdataSplit[1].split(']]>');
            this.rawContent = cdataSplit[0].trim();
            this.classRightPart = ']]>' + cdataSplit[1]
            this.makeEditor();
            this.readSections();
            this.renderNextSection(true);
        }).catch( err => {
            console.error(err);
        })
    }

    saveDocument() {
        //throttle auto save frequency to every 10 seconds
        if (!this.busy) {
            this.busy = true;
            window.setTimeout( () => {
                this.document.content = this.classLeftPart + this.editor.getModel().getValue() + this.classRightPart;
                this.document.save().then( res => {
                    console.log('saved');
                    //TODO: Catch Save error here
                }).catch( err => {
                    //TODO: Catch HTTP error here
                });
                this.busy = false
            },10000)
        }
    }

    makeEditor() {
        this.editor = monaco.editor.create(this.editorContentEl,{
            value: this.rawContent,
            language: 'markdown',
            theme: 'vs',
            automaticLayout: true,
            minimap: {enabled:true},
            lineNumbers: false
        })
        //register document has been edited event
        this.editor.onDidChangeModelContent( ev => this.onDidChangeModelContent(ev));
    }

    onDidChangeModelContent(ev) {
        this.saveDocument()
        this.nextSectionToRender = this.getSectionIdThatIsChanging(ev);
        this.renderNextSection()
        this.changeHash('section-' + (this.nextSectionToRender-1))
    }

    getSectionIdThatIsChanging(ev) {
        this.readSections();
        return this.content.slice(0,ev.changes[0].rangeOffset).split('```').length - 1;
    }

    readSections() {
        this.content = this.editor.getModel().getValue();
        this.sections = this.content.split('```');
    }

    renderNextSection(chainReaction = false) {
        let id = this.nextSectionToRender;
        if (this.sections[id] === undefined) return;  //no more sections, stop
        this.nextSectionToRender++;
        let section = this.getSection(id);
        section.id = id;
        section.type = section.type.trim();
        if (section.type === 'mmd' || section.type === '') return this.drawMoustacheMarkdownSection(section.id,section.content,chainReaction);
        if (section.type.toUpperCase() === 'SQL') return this.runInlineSQL(section,chainReaction)
        if (section.type.toUpperCase() === 'MERMAID') return this.runMermaid(section,chainReaction)
        if (section.type.toUpperCase() === 'CHARTJS') return this.runChartJS(section,chainReaction)
        if (section.type.toUpperCase() === 'JAVASCRIPT') return this.runJavaScript(section,chainReaction)
        if (section.type.toUpperCase() === 'FORM') return this.runForm(section,chainReaction)
        if (section.type.toUpperCase() === 'CODE') return this.renderCode(section,chainReaction)
        if (section.type.toUpperCase() === 'BREAK') return this.renderPageBreak(section,chainReaction)
        this.renderErrorPanel(section,`Unknown content type: ${section.type}`)
    }

    drawMoustacheMarkdownSection(id,content,chainReaction) {
        this.renderSectionElement(id,marked.parse(mustache(content,this.data)));
        if (chainReaction) this.renderNextSection(chainReaction);
    }

    renderCode(section,chainReaction) {
        this.drawMoustacheMarkdownSection(section.id,'```' + section.content + '```',chainReaction);
    }

    renderPageBreak(section,chainReaction) {
        let html = `<div style="page-break-after: always;"></div>
                    <div>&nbsp;
                    </div>`
        this.renderHTML(section,html);
        if (chainReaction) this.renderNextSection(chainReaction);
    }

    runForm(section,chainReaction) {
        this.renderHTML(section,section.content);
        if (chainReaction) this.renderNextSection(chainReaction);
        let sectionEl = document.getElementById('section-' + section.id);
        let selects = sectionEl.querySelectorAll('select')
        for (let i=0; i<selects.length; i++) {
            let name = selects[i].dataset.options.split('.');
            this.data[name[0]].map( item => {
                selects[i].add(new Option(item[name[1]]))
            })
            selects[i].addEventListener('change', ev => {
                this.data[selects[i].name]=selects[i].value
                this.nextSectionToRender = section.id + 1;
                if (chainReaction) this.renderNextSection(chainReaction);
            })
        }
    }

    runJavaScript(section,chainReaction) {
        this.clearPanel(section);
        let content = section.content;
        if (content.indexOf('#parent') > -1) {
            content = content.replace('#parent',`#section-${section.id}`)
        }
        //try {
            let html = new Function("data",content)(this.data);
            if (html !== undefined) this.renderHTML(section,html);
            if (chainReaction) this.renderNextSection(chainReaction);
        //} catch(err) {
        //    let errorInfo = `<pre>${err.toString()}</pre>`;
        //    this.renderErrorPanel(section,errorInfo)
        //}
    }

    runChartJS(section,chainReaction) {
        let html=`<div><canvas id="chart-${section.id}" width="400" height="400"></canvas></div>`
        this.renderHTML(section,html);
        const ctx = document.getElementById(`chart-${section.id}`).getContext('2d');
        let chartData = Function("data",`return ${section.content}`)(this.data);
        console.log('CHART DATA');
        console.log(chartData);
        new Chart(ctx,chartData);
        if (chainReaction) this.renderNextSection(chainReaction);
    }

    runMermaid(section,chainReaction) {
        console.log(this.data);
        let content = mustache(section.content,this.data)
        console.log(content);
        let html = `<div class="mermaid">
                        ${content}
                    </div>`
        this.renderHTML(section,html);
        Mermaid.init();
        if (chainReaction) this.renderNextSection(chainReaction);
    }

    runInlineSQL(section,chainReaction) {
        if (this.queryBusy) return;
        this.queryBusy = true;
        window.setTimeout( () => {
            let params = [];
            if (section.params.params) {
                section.params.params.map( name => {
                    try {
                        let val = this.data[name];
                        params.push(val);
                    } catch(err) {
                        //TODO
                    }
                })
            }
            this.renderInlineSQLDebugPanel(section, 'Running Query')
            System.Query(this.ns, section.content, params).then(data => {
                this.queryBusy = false;
                this.data[section.params.name] = data.result.content;
                if (data.status.errors.length > 0) {
                    let errorInfo = `<pre>${section.content}\n\n${JSON.stringify(data.status.errors,null, 4)}</pre>`;
                    this.renderErrorPanel(section,errorInfo)
                } else if (section.params.debug > 0) {
                    let debugData = data.result.content.slice(0,section.params.debug)
                    let debugInfo = `<br>Results: <i>(first ${section.params.debug} records)</i><br><pre>${section.content}\n\n${JSON.stringify(debugData,null, 4)}</pre>`;
                    this.renderDebugPanel(section,debugInfo)
                } else {
                    this.clearPanel(section);
                }
                this.renderNextSection(true);
                console.log(this.data)
            })
        },500)
    }

    renderInlineSQLDebugPanel(section,data) {
        let content = "```json\n SQL DEBUG: " + JSON.stringify(data).slice(0,1000) + "\n```"
        this.drawMoustacheMarkdownSection(section.id,content);
    }

    renderDebugPanel(section,text) {
        let html = `<div class="debug-panel"><div class="panel-title">DEBUG</div>${text}</div>`
        this.renderSectionElement(section.id,html)
    }

    renderErrorPanel(section,text) {
        let html = `<div class="error-panel"><div class="panel-title">ERROR</div>${text}</div>`
        this.renderSectionElement(section.id,html)
    }

    renderHTML(section,html) {
        this.renderSectionElement(section.id,html)
    }

    clearPanel(section) {
        this.renderSectionElement(section.id,'')
    }

    renderSectionElement(id,html) {
        console.log('update section ',id)
        let sectionEl = document.getElementById('section-' + id);
        if (sectionEl === null) {
            sectionEl = document.createElement('section');
            sectionEl.id = 'section-' + id
            sectionEl.classList.add('page-break');
            this.previewContentEl.appendChild(sectionEl)
        }
        sectionEl.innerHTML = html;
    }

    getSection(id) {
        let section = {type:"mmd",content:'',params:'',error:''}
        if (id === 0) {
            section.content = this.sections[id]
            return section;
        }
        section.content = this.sections[id].split('\n');
        let typeAndParams = section.content.shift()
        typeAndParams = typeAndParams.split(' ');
        section.content = section.content.join('\n')
        if (typeAndParams[0] === '') return section;  //no type defined, so let it default to type mmd
        section.type = typeAndParams.shift();
        try {
            let params = typeAndParams.join(' ');
            section.params = JSON.parse(params);
        } catch(err) {
            console.log('params extract failed?')
        }
        return section;
    }

    changeHash(name) {
        let url = new URL(document.URL);
        url.hash = '#' + name;
        document.location.href = url.href;
        this.editor.focus();
    }

}