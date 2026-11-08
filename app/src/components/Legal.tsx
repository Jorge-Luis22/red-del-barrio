import { CONTACT_EMAIL } from '../lib/mode';

/** Términos y privacidad del piloto, en lenguaje simple. Se muestra al unirse y desde Perfil. */
export default function Legal({ onClose }: { onClose: () => void }) {
  const contact = CONTACT_EMAIL || 'la persona que te dio el código del barrio';
  return (
    <div className="tutorial-backdrop">
      <div className="tutorial legal" role="dialog" aria-modal="true" aria-labelledby="legal-title">
        <div className="tutorial-top">
          <span className="tutorial-count">Piloto · versión 1</span>
          <button type="button" className="tutorial-skip" onClick={onClose}>
            Cerrar
          </button>
        </div>
        <h2 id="legal-title">Términos y privacidad</h2>

        <h4>Qué es</h4>
        <p>
          Red del barrio es una prueba piloto para que vecinos se ayuden entre sí. No es un servicio de emergencias, no
          es una empresa de servicios y no garantiza a nadie. Quienes se ayudan lo acuerdan entre ellos.
        </p>

        <h4>Quién puede usarla</h4>
        <p>Solo personas de 18 años o más, que recibieron el código del barrio.</p>

        <h4>Qué datos guardamos</h4>
        <ul>
          <li>El nombre y la zona que escribes al entrar, y una ubicación aproximada de unos 1 000 m si das permiso de GPS.</li>
          <li>Lo que publicas: pedidos, ofertas, propuestas, alertas, calificaciones y mensajes.</li>
          <li>Un identificador de cuenta automático. No pedimos correo, teléfono ni contraseña.</li>
        </ul>

        <h4>Qué ven los demás</h4>
        <ul>
          <li>Los vecinos del piloto ven tu nombre, tu zona aproximada y tus publicaciones.</li>
          <li>Tu dirección exacta y tu posición exacta nunca salen de tu teléfono.</li>
          <li>Los chats solo los ven las dos personas del trato. Compartir una dirección en el chat es decisión tuya.</li>
          <li>Las alertas de violencia son privadas: se quedan en tu teléfono.</li>
          <li>
            Los chats no tienen cifrado de extremo a extremo: quien administra el servidor del piloto podría, técnicamente,
            acceder a lo guardado en él. Por eso no compartas contraseñas, claves ni datos bancarios.
          </li>
        </ul>

        <h4>Emergencias</h4>
        <p>
          En una emergencia llama primero a la PNP (105), Bomberos (116) o el SAMU (106). La app solo avisa a tus vecinos;
          puede fallar o tardar, y nadie está obligado a responder.
        </p>

        <h4>Convivencia</h4>
        <p>
          No se permite acosar, estafar, publicar información falsa ni exponer a otra persona. Puedes reportar y bloquear
          a cualquier vecino. Quien organiza el piloto puede suspender cuentas. La app no maneja pagos: cualquier cobro se
          acuerda y se hace fuera de ella, bajo tu responsabilidad.
        </p>

        <h4>Tu cuenta</h4>
        <p>
          La cuenta vive en este teléfono. Si borras los datos del navegador o cambias de teléfono, no podrás recuperarla
          (podrás crear otra con el código). Desde Perfil puedes eliminar tu cuenta y lo que publicaste en el servidor.
        </p>

        <h4>Dudas, reportes y pedidos sobre tus datos</h4>
        <p>
          Escribe a <strong>{contact}</strong>. Puedes pedir ver, corregir o borrar tus datos.
        </p>

        <div className="tutorial-actions">
          <button type="button" className="btn" onClick={onClose}>
            Entendido
          </button>
        </div>
      </div>
    </div>
  );
}
