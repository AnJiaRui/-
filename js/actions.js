(function (window) {
  var app = window.JinShanOCR;
  app.copyButton.addEventListener('click', function () { if (!app.lastText) return; if (navigator.clipboard) { navigator.clipboard.writeText(app.lastText); } else { window.prompt('Copy the text below:', app.lastText); } });
  app.saveButton.addEventListener('click', function () { if (!app.lastText) return; var blob = new Blob([app.lastText], { type: 'text/plain;charset=utf-8' }); var link = document.createElement('a'); link.href = window.URL.createObjectURL(blob); link.download = 'recognition-result.txt'; link.click(); window.URL.revokeObjectURL(link.href); });
}(window));
