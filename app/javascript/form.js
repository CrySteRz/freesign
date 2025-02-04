import { createApp, reactive } from "vue";

import Form from "./submission_form/form";
import DownloadButton from "./elements/download_button";
import ToggleSubmit from "./elements/toggle_submit";

const safeRegisterElement = (name, element, options = {}) =>
  !window.customElements.get(name) &&
  window.customElements.define(name, element, options);

safeRegisterElement("download-button", DownloadButton);
safeRegisterElement("toggle-submit", ToggleSubmit);
safeRegisterElement(
  "submission-form",
  class extends HTMLElement {
    connectedCallback() {
      this.appElem = document.createElement("div");

      this.app = createApp(Form, {
        submitter: JSON.parse(this.dataset.submitter),
        canSendEmail: this.dataset.canSendEmail === "true",
        goToLast: this.dataset.goToLast === "true",
        attribution: this.dataset.attribution !== "false",
        withConfetti: this.dataset.withConfetti !== "false",
        withDisclosure: this.dataset.withDisclosure === "true",
        withTypedSignature: this.dataset.withTypedSignature !== "false",
        authenticityToken: document.querySelector('meta[name="csrf-token"]')
          ?.content,
        values: reactive(JSON.parse(this.dataset.values)),
        completedButton: JSON.parse(this.dataset.completedButton || "{}"),
        withQrButton: true,
        completedMessage: JSON.parse(this.dataset.completedMessage || "{}"),
        completedRedirectUrl: this.dataset.completedRedirectUrl,
        attachments: reactive(JSON.parse(this.dataset.attachments)),
        fields: JSON.parse(this.dataset.fields),
      });

      this.app.mount(this.appElem);

      this.appendChild(this.appElem);
    }

    disconnectedCallback() {
      this.app?.unmount();
      this.appElem?.remove();
    }
  }
);
