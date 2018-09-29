class MyWebComponent extends HTMLElement {
  static get observedAttributes() {
    return ["name"];
  }

  connectedCallback() {
    const elmNode = document.createElement("div");

    this.appendChild(elmNode);

    this.elmRuntime = Elm.Main.init({
      node: elmNode,
      flags: this.getAttribute("name") || "Unknown Person"
    });
  }

  attributeChangedCallback(name, oldValue, newValue) {
    //TODO implement this
  }
}

customElements.define("my-webcomponent", MyWebComponent);

let count = 0;

const reload = () => {
  const oldElement = document.querySelector("my-webcomponent");
  const newElement = document.createElement("my-webcomponent");

  const name = oldElement.getAttribute("name")
  const rotatedName = name.repeat(2).slice(1, name.length + 1);

  newElement.setAttribute("name", rotatedName);
  oldElement.parentElement.replaceChild(newElement, oldElement);

  if (count++ < 2000) {
    requestAnimationFrame(reload);
  }
};

requestAnimationFrame(reload);
