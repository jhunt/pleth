;(function () {
  let data;
  function load(the) {
    data = the ? the : data

    const root = document.querySelector('#pleth')
    while (root.firstChild) { root.removeChild(root.firstChild) }

    data.obs = data.obs.filter(ob => !ob.file.match(/\.html$/))
    if (data.obs.length > 0) {
      const ob = data.obs[0]
      data.obs = data.obs.slice(1)

      if ('content' in document.createElement('template')) {
        const template = document.querySelector('template[rel=classify]')
        const clone = template.content.cloneNode(true);

        clone.querySelector('[rel=seen]').innerText = data.seen
        clone.querySelector('[rel=total]').innerText = data.total
        clone.querySelector('[rel=percent]').innerText = data.total == 0 ? '0' : (100 * data.seen / data.total).toFixed(2)
        clone.querySelector('img').setAttribute('src', '/'+ob.file)
        clone.querySelector('pre').innerText = JSON.stringify(ob.exif, null, 2)
        clone.querySelector('input[name=id]').value = ob.sha256
        root.appendChild(clone)

      } else {
        const div = document.createElement('div')
        div.classList.add('error');
        div.innerText = 'your browser does not support <template> elements...'
        root.appendChild(div)
      }
    } else {
      root.innerText = 'ALL DONE!';
    }
  }

  document.addEventListener('DOMContentLoaded', () => {
    fetch('/v1/next/20')
      .then(r => r.json())
      .then(load)

    document.querySelector('#pleth').addEventListener('submit', event => {
      event.preventDefault()
      console.log(event.target.elements)

      const data = {}
      Array.from(event.target.elements).forEach(e => {
        if (e.name) {
          data[e.name] = e.value
        }
      })
      console.log(data)

      fetch('/v1/ob/'+data.id, {
        method: 'POST',
        mode: 'cors',
        cache: 'no-cache',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          tags: data.tags.split(/\s*;\s*/),
          metadata: {}
        }),
      }).then(() => load())
    })
  })
})();
