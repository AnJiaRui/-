(function (window) {
  var app = window.JinShanOCR;
  function readFile(file) {
    if (app.busy) { app.line('System busy: the previous image is still being recognized.', 'error'); return; }
    if (!file || !file.type || file.type.indexOf('image/') !== 0) { app.line('Error: please drop an image file.', 'error'); return; }
    app.busy = true;
    app.body.className = 'terminal-body has-output';
    app.copyButton.disabled = true;
    app.saveButton.disabled = true;
    app.line('');
    app.line('C:\\JinShan> ocr "' + file.name + '"', 'prompt');
    app.line('File loaded: ' + Math.round(file.size / 1024) + ' KB', 'gray');
    app.line('Starting the local OCR engine...', 'yellow');
    window.JinShanOCR.recognize(file);
  }
  app.readFile = readFile;
  app.body.addEventListener('dragenter', function (event) { event.preventDefault(); app.dragState(true); });
  app.body.addEventListener('dragover', function (event) { event.preventDefault(); if (event.dataTransfer) event.dataTransfer.dropEffect = 'copy'; app.dragState(true); });
  app.body.addEventListener('dragleave', function (event) { if (event.target === app.body) app.dragState(false); });
  app.body.addEventListener('drop', function (event) { event.preventDefault(); app.dragState(false); if (event.dataTransfer && event.dataTransfer.files.length) readFile(event.dataTransfer.files[0]); });
  document.getElementById('chooseButton').addEventListener('click', function () { app.input.click(); });
  app.input.addEventListener('change', function () { if (app.input.files.length) readFile(app.input.files[0]); app.input.value = ''; });
}(window));
