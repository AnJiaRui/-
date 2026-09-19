(function (window, document) {
  var api = {
    body: document.getElementById('terminalBody'),
    output: document.getElementById('output'),
    input: document.getElementById('fileInput'),
    copyButton: document.getElementById('copyButton'),
    saveButton: document.getElementById('saveButton'),
    lastText: '',
    busy: false,
    worker: null,
    workerLanguage: '',
    line: function (text, className) { var node = document.createElement('div'); node.className = 'line ' + (className || ''); node.appendChild(document.createTextNode(text)); this.output.appendChild(node); return node; },
    result: function (text) { var node = document.createElement('div'); node.className = 'result'; node.appendChild(document.createTextNode(text)); this.output.appendChild(node); },
    dragState: function (active) { this.body.className = active ? 'terminal-body dragging' : 'terminal-body'; }
  };
  window.JinShanOCR = api;
}(window, document));
