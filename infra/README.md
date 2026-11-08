# Infra: Synapse + Caddy

Chat de Matrix con un homeserver propio. Un room por trato; la app se conecta
por Client-Server API y Element se usa como cliente de prueba.

## Levantar

1. `Copy-Item .env.example .env` y pon tu dominio real (DuckDNS gratis).
2. Apunta el registro A/AAAA del dominio a la IP pública del VPS. Puertos: 80, 443 y 8448 abiertos.
3. `docker compose up -d`
4. Verificar: abrir `https://TU_DOMINIO/_matrix/client/versions` → debe responder JSON.

## Crear usuarios (primer arranque genera homeserver.yaml solo)

```bash
docker compose exec synapse register_new_matrix_user -c /data/homeserver.yaml -u vecino1 -p claveSegura123 --no-admin http://localhost:8008
```

## Token para la app

```bash
curl -X POST https://TU_DOMINIO/_matrix/client/v3/login \
  -H "Content-Type: application/json" \
  -d '{"type":"m.login.password","identifier":{"type":"m.id.user","user":"vecino1"},"password":"claveSegura123"}'
```

Copia el `access_token` en `app/.env.local`:

```
VITE_MATRIX_HOMESERVER=https://TU_DOMINIO
VITE_MATRIX_TOKEN=<access_token>
```

## Probar con Element

1. Abrir https://app.element.io → "Editar" homeserver → poner `https://TU_DOMINIO`.
2. Entrar con otra cuenta (vecino2). Los mensajes deben aparecer en ambos lados.

## Notas

- E2EE desactivado en la demo (los rooms se crean sin `m.room.encryption`). Ver `docs/DECISIONES.md`.
- La app usa una sola cuenta por dispositivo (env token). Cuenta por usuario = P1.
- Auto-registro de cuentas al registrarse en la app: añadir `registration_shared_secret` a
  `synapse/data/homeserver.yaml` y llamar `/_synapse/admin/v1/register` (ver Guía técnica).
