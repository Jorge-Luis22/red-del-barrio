# Piloto real de Red del barrio

El piloto es la misma app, publicada en **otra dirección**, con vecinos reales:

| | Demo (jurado) | Piloto (vecinos) |
|---|---|---|
| Entrada | abre directo, vecinos de ejemplo | **código del barrio** + nombre + zona (18+) |
| Cuentas | no hay | una por teléfono, automática (sin correo ni contraseña) |
| Datos de ejemplo | sí | **ninguno** |
| Chats | tabla abierta | **solo los dos del trato** (lo exige el servidor) |
| Seguridad | — | reportar, bloquear, eliminar mi cuenta, términos |

Se compila con `VITE_APP_MODE=pilot` (y `VITE_CONTACT_EMAIL`). Sin esa variable sale la demo.

## Puesta en marcha (una sola vez)

1. Supabase → *Authentication → Sign In / Providers* → activar **Allow anonymous sign-ins**.
2. Supabase → *SQL Editor* → ejecutar `supabase/migrations/0004_pilot.sql`.
3. En el mismo editor, fijar el código del barrio (mínimo 10 caracteres, que no sea adivinable):

   ```sql
   select public.pilot_set_code('XXXX-XXXX-XXXX');
   ```
4. Compilar con las claves de Supabase y subir la carpeta `dist` a un sitio nuevo de Netlify.
5. Entrar tú primero con el código y probar: publicar, proponer, chatear con otro teléfono.

## Moderar (SQL Editor de Supabase)

```sql
-- Quién está en el piloto
select user_id, display_name, zone, joined_at, banned from pilot_members order by joined_at desc;

-- Reportes recientes, con nombre del reportado
select r.created_at, r.reason, r.entity, r.entity_id, t.display_name as reportado, u.display_name as reporto
from pilot_reports r
left join pilot_members t on t.user_id = r.target
left join pilot_members u on u.user_id = r.reporter
order by r.created_at desc;

-- Vetar / levantar el veto
update pilot_members set banned = true  where user_id = '…';
update pilot_members set banned = false where user_id = '…';

-- Cambiar el código (solo afecta a quien entre después)
select public.pilot_set_code('NUEVO-CODIGO');
```

Un vecino vetado deja de subir y de leer, y los demás dejan de recibir lo suyo. Lo que ya se había
descargado en otros teléfonos no se retira.

## Qué hay que saber (límites reales)

- **Cuenta anclada al teléfono.** Si el vecino borra los datos del navegador o cambia de teléfono, pierde
  la cuenta (puede crear otra con el código). La app lo avisa al entrar y en Perfil.
- **Sin notificaciones push.** Los avisos y chats se ven al abrir la app (se sincroniza cada 4 s mientras está abierta).
- **Un vetado puede crear otra cuenta** con el mismo código: si pasa, cambia el código.
- **Altas por IP.** Supabase limita las cuentas anónimas nuevas por IP (por defecto 30 por hora); si todo un
  barrio entra desde el mismo wifi, súbelo en *Authentication → Rate Limits*.
- **Chats sin cifrado de extremo a extremo.** Quien administre Supabase podría leerlos técnicamente; los términos lo dicen.
- **Datos personales (Ley 29733).** Se guardan nombre, zona aproximada y lo que el vecino publica. Conviene una
  revisión legal antes de abrirlo más allá de un grupo pequeño (consentimiento, plazo de conservación, y si
  corresponde inscribir el banco de datos). Esto no es asesoría legal.
- **Emergencias.** La app avisa a vecinos; no reemplaza a la PNP (105), Bomberos (116) ni al SAMU (106).

## Lanzamiento recomendado

1. 5–10 vecinos conocidos una semana (un grupo de WhatsApp para dudas).
2. Revisar `pilot_reports` cada día los primeros días.
3. Abrir a más gente solo si hay reportes atendidos y los términos fueron revisados.
