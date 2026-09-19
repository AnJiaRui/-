(function (window, document) {
  var app = window.JinShanOCR;
  function sendAutoType(text) {
    var request = new XMLHttpRequest();
    request.open('POST', 'http://127.0.0.1:8765/result', true);
    request.setRequestHeader('Content-Type', 'text/plain;charset=UTF-8');
    request.onreadystatechange = function () {
      if (request.readyState === 4 && request.status >= 200 && request.status < 300) app.line('Auto type request sent. Switch to the target window.', 'green');
    };
    request.send(text);
  }
  function createWorker(language) {
    app.line('Loading local OCR model (' + language + ')...', 'yellow');
    return window.Tesseract.createWorker(language, 1, {
      workerPath: './tesseract/worker.min.js',
      langPath: './tesseract/lang-data',
      corePath: './tesseract/tesseract-core.wasm.js',
      logger: function (info) {
        if (info.status === 'loading tesseract core') app.line('Loading OCR core...', 'gray');
        if (info.status === 'loading language traineddata') app.line('Loading language data...', 'gray');
        if (info.status === 'recognizing text') app.line('Recognition progress: ' + Math.round(info.progress * 100) + '%', 'gray');
      }
    });
  }
  app.recognize = function (file) {
    if (!window.Tesseract) { app.line('Error: tesseract/tesseract.min.js was not found.', 'error'); app.line('Add Tesseract.js, the worker, and language data to the tesseract folder, then try again.', 'error'); app.busy = false; return; }
    var language = document.getElementById('language').value;
    var workerPromise;
    if (app.worker && app.workerLanguage === language) {
      workerPromise = Promise.resolve(app.worker);
      app.line('Reusing the loaded local OCR model.', 'gray');
    } else {
      if (app.worker) { app.worker.terminate(); app.worker = null; }
      workerPromise = createWorker(language).then(function (worker) { app.worker = worker; app.workerLanguage = language; return worker; });
    }
    workerPromise.then(function (worker) {
      app.line('Recognizing image...', 'yellow');
      return worker.recognize(file);
    }).then(function (data) {
      app.lastText = (data.data.text || '').replace(/^\s+|\s+$/g, '');
      app.line('');
      app.line('Recognition complete: ' + Math.round(data.data.confidence || 0) + '% confidence', 'green');
      app.result(app.lastText || '[No text detected]');
      app.copyButton.disabled = !app.lastText;
      app.saveButton.disabled = !app.lastText;
      app.busy = false;
      try { sendAutoType(app.lastText); } catch (error) { /* Auto mode is optional. */ }
    }).catch(function (error) { app.line('Recognition failed: ' + error.message, 'error'); app.busy = false; });
  };
}(window, document));
