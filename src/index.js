class MyWebComponent extends HTMLElement {
  static get observedAttributes() {
    return ["name"];
  }

  connectedCallback() {
    const elmNode = document.createElement("div");

    this.appendChild(elmNode);

    this.elmRuntime = Elm.Component.init({
      node: elmNode,
      flags: this.getAttribute("name") || "Unknown Person"
    });

    this.elmRuntime.ports.updateValue.subscribe((str) => {
      this.dispatchEvent(new CustomEvent("change", {
        detail: str
      }))
      this.setAttribute("name", str);
    });
  }

  disconnectedCallback() {
    this.elmRuntime.ports.updateValue.unsubscribe();
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (!this.elmRuntime) {
      return;
    }
    switch (name) {
      case "name":
        this.elmRuntime.ports.values.send(newValue);
    }
  }
}

customElements.define("my-webcomponent", MyWebComponent);

Elm.Host.init({
  node: document.querySelector("#host")
}); 