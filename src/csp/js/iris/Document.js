
export class Document {

    constructor(ns,name,content) {
        this.ns = ns;
        this.name = name;
        this.content = content;
    }

    static open(ns,docName) {
        return new Promise( (resolve,reject) => {
            let url = `/api/atelier/v1/${encodeURI(ns)}/doc/${encodeURI(docName)}`;
            fetch(url).then( res => res.json()).then( data => {
                resolve(new Document(ns,docName,data.result.content.join(String.fromCharCode(10))));
            }).catch( err => {
                reject(err);
            })
        })
    }

    save() {
        return fetch(`/api/atelier/v1/${encodeURI(this.ns)}/doc/${encodeURI(this.name)}?ignoreConflict=1`,{
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                "enc" : false,
                "content" : this.content.split(String.fromCharCode(10))
            })
        })
    }

    compile() {
        return fetch(`/api/atelier/v1/${encodeURI(this.ns)}/action/compile`,{
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify([this.name])
        })
    }

    static listAll(ns) {
        //TODO, select all classes that extend kozo.Base using System.js query
    }

}