using System;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Reflection;

namespace Capa_Datos
{
    // ── Extiende BasededatosDataContext con SPs y aliases no presentes en el DBML ──
    public partial class BasededatosDataContext
    {
        // Aumenta el timeout a 120 s para todas las instancias
        partial void OnCreated() => CommandTimeout = 120;
        // ── sp_desbloquear_usuario ─────────────────────────────────────
        [global::System.Data.Linq.Mapping.FunctionAttribute(Name = "dbo.sp_desbloquear_usuario")]
        public int sp_desbloquear_usuario(
            [global::System.Data.Linq.Mapping.ParameterAttribute(DbType = "Int")] int usu_id)
        {
            IExecuteResult result = ExecuteMethodCall(
                this, (MethodInfo)MethodInfo.GetCurrentMethod(), usu_id);
            return (int)result.ReturnValue;
        }

        // ── sp_reset_intentos_si_nuevo_dia ────────────────────────────
        // Sobrecarga de compatibilidad: el SP en BD tiene 0 parámetros.
        // Delega a la versión sin parámetros generada por el designer.
        public int sp_reset_intentos_si_nuevo_dia(int? usu_id)
            => sp_reset_intentos_si_nuevo_dia();

        // ── sp_login ──────────────────────────────────────────────────
        [global::System.Data.Linq.Mapping.FunctionAttribute(Name = "dbo.sp_login")]
        public int sp_login(
            [global::System.Data.Linq.Mapping.ParameterAttribute(Name = "nick",      DbType = "VarChar(50)")]  string nick,
            [global::System.Data.Linq.Mapping.ParameterAttribute(Name = "password",  DbType = "VarChar(50)")]  string password,
            [global::System.Data.Linq.Mapping.ParameterAttribute(Name = "resultado", DbType = "Int")]          ref int    resultado,
            [global::System.Data.Linq.Mapping.ParameterAttribute(Name = "mensaje",   DbType = "VarChar(200)")] ref string mensaje)
        {
            IExecuteResult result = ExecuteMethodCall(
                this, (MethodInfo)MethodInfo.GetCurrentMethod(),
                nick, password, resultado, mensaje);
            resultado = (int)result.GetParameterValue(2);
            mensaje   = (string)result.GetParameterValue(3);
            return (int)result.ReturnValue;
        }

        // ── Aliases de ortografía ──────────────────────────────────────
        // El designer generó: encriptacon / desencriptacon (sin 'i' al final).
        // El código llama con dos variantes distintas; ambas delegan al
        // método ya mapeado en el designer para no crear un segundo binding SQL.

        // Variante A — usada en CN_tbl_usuarios
        public Binary encritacion(string clave)    => encriptacon(clave);
        public string desencritacion(Binary clave) => desencriptacon(clave);

        // Variante B — usada en register.aspx.cs y RecuperarPass.aspx.cs
        public Binary encriptacion(string clave)    => encriptacon(clave);
        public string desencriptacion(Binary clave) => desencriptacon(clave);
    }
}
