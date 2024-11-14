import { Ricoh360CameraPlugin } from 'richon360-capacitor-plugin';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    Ricoh360CameraPlugin.echo({ value: inputValue })
}
