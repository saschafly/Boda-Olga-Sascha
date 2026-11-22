# Configuración del panel privado de invitados

El código del formulario y del panel está preparado para Supabase. Para que funcione de verdad hay que crear el proyecto y dar de alta a los dos administradores. No publiques claves secretas.

## 1. Crear el proyecto
1. Crea un proyecto en https://supabase.com/.
2. En **SQL Editor**, ejecuta todo el contenido de `supabase/schema.sql`.
3. En **Authentication → Providers → Email**, deja activado Email. Desactiva el registro público (Sign ups) cuando hayas creado las dos cuentas de administración.
4. En **Project Settings → API**, copia la Project URL y la clave **anon / publishable**. Nunca uses la clave `service_role` o una secret key en la web.

## 2. Configurar la web
1. En el repositorio, copia `supabase-config.example.js` a un archivo llamado `supabase-config.js`.
2. Sustituye los dos valores de ejemplo por la Project URL y la clave anon/publishable.
3. No subas `supabase-config.js` al repositorio. Está incluido en `.gitignore`. Añádelo localmente al publicar el sitio. Si GitHub Pages publica directamente desde la rama, el archivo de configuración debe estar disponible en el despliegue; para evitar guardar la clave en Git, se puede generar en GitHub Actions con un secret.

## 3. Crear las cuentas de Olga y Sascha
1. En **Authentication → Users**, crea una cuenta para cada uno con sus correos y contraseñas.
2. Copia el UUID de cada usuario.
3. En SQL Editor ejecuta (sustituye los dos UUID):
   ```sql
   insert into public.rsvp_admins (user_id)
   values ('UUID-DE-OLGA'), ('UUID-DE-SASCHA');
   ```
   Solo esos usuarios podrán leer, exportar y gestionar las respuestas. Conocer la dirección /admin no concede acceso.

## 4. Publicar y probar
- La página de administración queda en `/admin/`.
- Comprueba que un invitado puede enviar una respuesta y que no puede leer ninguna respuesta.
- Comprueba que una sesión no autorizada no puede ver el panel ni consultar la tabla.
- Activa la confirmación de correo o contraseñas seguras para las dos cuentas.

## Protección de datos
La web usa la clave pública de Supabase, protegida por Row Level Security. Los visitantes solo tienen permiso de INSERT; no tienen SELECT. Las cuentas autorizadas se registran en `rsvp_admins` y las políticas de base de datos bloquean cualquier lectura por parte de invitados. No añadas nunca la clave service_role al HTML, JavaScript ni al repositorio.
