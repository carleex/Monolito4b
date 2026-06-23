using System;
using System.Collections.Generic;
using System.Linq;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_usuarios
    {
        // ── Lectura ───────────────────────────────────────────────────────────
        public static List<tbl_usuario> ListaUsuario()
        {
            using (var dc = new BasededatosDataContext())
                return dc.tbl_usuario.Where(u => u.usu_estado == 'A').ToList();
        }

        public static List<tbl_usuario> ListarTodos()
        {
            using (var dc = new BasededatosDataContext())
                return dc.tbl_usuario.OrderBy(u => u.usu_nombres).ToList();
        }

        public static List<tbl_usuario> Buscar(string q)
        {
            q = (q ?? "").Trim().ToLower();
            using (var dc = new BasededatosDataContext())
                return dc.tbl_usuario
                    .Where(u => q == ""
                        || u.usu_cedula.Contains(q)
                        || u.usu_nick.Contains(q)
                        || u.usu_nombres.Contains(q)
                        || u.usu_apellidos.Contains(q))
                    .OrderBy(u => u.usu_nombres)
                    .ToList();
        }

        public static tbl_usuario ObtenerPorId(int id)
        {
            using (var dc = new BasededatosDataContext())
                return dc.tbl_usuario.FirstOrDefault(u => u.usu_id == id);
        }

        public static bool ExisteCorreo(string correo, int excluirId = 0)
        {
            if (string.IsNullOrWhiteSpace(correo)) return false;
            using (var dc = new BasededatosDataContext())
                return dc.tbl_usuario.Any(u => u.usu_correo == correo && u.usu_id != excluirId);
        }

        public static bool ExisteNick(string nick, int excluirId = 0)
        {
            if (string.IsNullOrWhiteSpace(nick)) return false;
            using (var dc = new BasededatosDataContext())
                return dc.tbl_usuario.Any(u => u.usu_nick == nick && u.usu_id != excluirId);
        }

        public static tbl_usuario traerced(string cedula)
        {
            using (var dc = new BasededatosDataContext())
                return dc.tbl_usuario.FirstOrDefault(u => u.usu_cedula == cedula
                    && (u.usu_estado == 'A' || u.usu_estado == 'T'));
        }

        public static tbl_usuario TraerPorCorreo(string correo)
        {
            using (var dc = new BasededatosDataContext())
                return dc.tbl_usuario.FirstOrDefault(u => u.usu_correo == correo
                    && (u.usu_estado == 'A' || u.usu_estado == 'T'));
        }

        // ── Inserción ─────────────────────────────────────────────────────────
        public static void registrarUsuario(tbl_usuario usuario)
        {
            using (var dc = new BasededatosDataContext())
            {
                usuario.usu_fecha_creacion = DateTime.Now;
                usuario.usu_estado = 'A';
                dc.tbl_usuario.InsertOnSubmit(usuario);
                dc.SubmitChanges();
            }
        }

        /// <summary>
        /// Crea un usuario desde el panel admin, cifrando la contraseña con la UDF encriptacon.
        /// </summary>
        public static bool Insertar(tbl_usuario u, string password, out string msg)
        {
            msg = "";
            try
            {
                using (var dc = new BasededatosDataContext())
                {
                    u.usu_contraseña  = dc.encriptacion(password);
                    u.usu_estado      = u.usu_estado == '\0' ? 'A' : u.usu_estado;
                    u.usu_fecha_creacion = DateTime.Now;
                    dc.tbl_usuario.InsertOnSubmit(u);
                    dc.SubmitChanges();
                }
                return true;
            }
            catch (Exception ex) { msg = ex.Message; return false; }
        }

        // ── Actualización restringida (solo admin puede cambiar: dirección, tipo, estado) ──
        public static bool ActualizarRestringido(int id, string direccion, int tusu_id, char estado, out string msg)
        {
            msg = "";
            try
            {
                using (var dc = new BasededatosDataContext())
                {
                    var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == id);
                    if (u == null) { msg = "Usuario no encontrado."; return false; }

                    u.usu_direccion = direccion;
                    u.tusu_id       = tusu_id;
                    u.usu_estado    = estado;

                    dc.SubmitChanges();
                }
                return true;
            }
            catch (Exception ex) { msg = ex.Message; return false; }
        }

        // ── Actualización ─────────────────────────────────────────────────────
        /// <summary>
        /// Actualiza todos los campos de tbl_usuario. Si password es vacío, conserva la contraseña actual.
        /// </summary>
        public static bool Actualizar(tbl_usuario datos, string passwordNuevo, out string msg)
        {
            msg = "";
            try
            {
                using (var dc = new BasededatosDataContext())
                {
                    var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == datos.usu_id);
                    if (u == null) { msg = "Usuario no encontrado."; return false; }

                    u.usu_cedula    = datos.usu_cedula;
                    u.usu_nombres   = datos.usu_nombres;
                    u.usu_apellidos = datos.usu_apellidos;
                    u.usu_direccion = datos.usu_direccion;
                    u.usu_celular   = datos.usu_celular;
                    u.usu_correo    = datos.usu_correo;
                    u.usu_nick      = datos.usu_nick;
                    u.usu_estado    = datos.usu_estado;
                    u.tusu_id       = datos.tusu_id;

                    if (!string.IsNullOrWhiteSpace(passwordNuevo))
                        u.usu_contraseña = dc.encriptacion(passwordNuevo);

                    dc.SubmitChanges();
                }
                return true;
            }
            catch (Exception ex) { msg = ex.Message; return false; }
        }

        // ── Baja lógica ───────────────────────────────────────────────────────
        public static bool BajaLogica(int id, out string msg)
        {
            msg = "";
            try
            {
                using (var dc = new BasededatosDataContext())
                {
                    var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == id);
                    if (u == null) { msg = "Usuario no encontrado."; return false; }
                    u.usu_estado = 'I';
                    dc.SubmitChanges();
                }
                return true;
            }
            catch (Exception ex) { msg = ex.Message; return false; }
        }

        // ── Desbloquear ───────────────────────────────────────────────────────
        public static bool Desbloquear(int id, out string msg)
        {
            msg = "";
            try
            {
                using (var dc = new BasededatosDataContext())
                {
                    var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == id);
                    if (u == null) { msg = "Usuario no encontrado."; return false; }
                    u.usu_estado   = 'A';
                    u.usu_intentos = 0;
                    dc.SubmitChanges();
                }
                return true;
            }
            catch (Exception ex) { msg = ex.Message; return false; }
        }

        // ── Autenticación (usada por login) ───────────────────────────────────
        public static bool autentixced(string cedula)
        {
            using (var dc = new BasededatosDataContext())
                return dc.tbl_usuario.Any(u => u.usu_cedula == cedula && u.usu_estado == 'A');
        }

        public static bool autentixcc(string cedula, string password)
        {
            using (var dc = new BasededatosDataContext())
                return dc.tbl_usuario.Any(u =>
                    u.usu_cedula == cedula &&
                    dc.desencritacion(u.usu_contraseña) == password &&
                    u.usu_estado == 'A');
        }

        public static tbl_usuario traerUsuario(string cedula, string password)
        {
            using (var dc = new BasededatosDataContext())
                return dc.tbl_usuario.FirstOrDefault(u =>
                    u.usu_cedula == cedula &&
                    dc.desencritacion(u.usu_contraseña) == password &&
                    (u.usu_estado == 'A' || u.usu_estado == 'T'));
        }
    }
}
