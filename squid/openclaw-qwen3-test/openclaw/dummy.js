setInterval(() => {}, 1 << 30);  // ~17 minutes interval → almost no CPU
// or even better:
setTimeout(() => {}, 2 ** 60);   // never fires in practice