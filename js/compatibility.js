(function (window, document) {
  var output = document.getElementById('output');
  var problems = [];
  if (!window.Worker) problems.push('This browser does not support Web Workers.');
  if (!window.WebAssembly) problems.push('This browser does not support WebAssembly.');
  if (!window.Promise) problems.push('This browser is too old for the local OCR engine.');
  if (problems.length) {
    var node = document.createElement('div');
    node.className = 'line error';
    node.appendChild(document.createTextNode('Compatibility warning: ' + problems.join(' ')));
    output.appendChild(node);
    var advice = document.createElement('div');
    advice.className = 'line yellow';
    advice.appendChild(document.createTextNode('Use a newer offline browser package, or install a legacy Tesseract.js build in the tesseract folder.'));
    output.appendChild(advice);
  }
}(window, document));
