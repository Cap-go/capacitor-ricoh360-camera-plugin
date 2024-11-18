import { Ricoh360Camera } from 'richon360-camera';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    Ricoh360Camera.echo({ value: inputValue })
}
