;(function () {
  function load(data) {
    const root = document.querySelector('#pleth')
    while (root.firstChild) { root.removeChild(root.firstChild) }

    const q = Object.fromEntries(document.location.search.replace(/^\?/, '').split('&').map(s => s.split(/=/, 2)))
    const tagged = {}
    data.filter(ob => !ob.file.match(/\.html$/)).forEach(ob => {
      (ob.tags || ['Unsorted']).forEach(tag => {
        if (q.tagged && q.tagged != tag) {
          return
        }
        tagged[tag] ||= [];
        tagged[tag].push(ob)
      })
    })

    if ('content' in document.createElement('template')) {
      const row = document.querySelector('template[rel=row]')
      const li  = document.querySelector('template[rel=li]')

      Object.entries(tagged).forEach(([tag, obs]) => {
        const aRow = row.content.cloneNode(true)
        aRow.querySelector('h2').innerText = tag

        const ol = aRow.querySelector('ol')
        obs.forEach(ob => {
          anLI = li.content.cloneNode(true)
          anLI.querySelector('a').setAttribute('href', '/'+ob.file)
          anLI.querySelector('img').setAttribute('src', '/'+ob.file)
          ol.appendChild(anLI)
        })
        root.appendChild(aRow)
      })

    } else {
      const div = document.createElement('div')
      div.classList.add('error');
      div.innerText = 'your browser does not support <template> elements...'
      root.appendChild(div)
    }
  }

  document.addEventListener('DOMContentLoaded', () => {
    fetch('/v1/obs')
      .then(r => r.json())
      .then(load)
  })
})();
