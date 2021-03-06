package acesso;

class GestaoBase {
	static inline var ENDPOINT =
			"https://servicos.acessocard.com.br/api2.0/Services/rest/GestaoAquisicaoCartao.svc";

	var token:TokenAcesso;

	public static function CriarToken(params:{ Email:String, Senha:String }):TokenAcesso
	{
		var email = StringTools.urlEncode(params.Email);
		var senha = StringTools.urlEncode(params.Senha);
		var res:Response<TokenAcesso> = doNetworkRequest(ENDPOINT, 'criar-token/$email/$senha', params);
		switch res.ResultCode {
		case 0:
			return res.Data;
		case 5, 99:  // unspecified, internal
			throw AcessoTemporaryError(res);
		case _:
			throw AcessoPermanentError(res);
		}
	}

	function new(token:TokenAcesso)
		this.token = token;

	function request(endpoint:String, api:String, data:Dynamic):Dynamic
	{
		var params:Params<Dynamic> = {
			Language : REST,
			NomeCanal : Webservice,
			RecId : 42,  // TODO get it as a param (but it's ignored by Acesso at the moment)
			TokenAcesso : token,
			Data : data
		}
		return doNetworkRequest(endpoint, api, params);
	}

	static function doNetworkRequest(endpoint:String, api:String, params:Dynamic):Dynamic
	{
		var ret:Dynamic = null;
		var url = '$endpoint/$api';
		var req = new haxe.Http(url);
		var log = new db.RemoteCallLog(url, "POST");

		req.addHeader("Content-Type", "application/json");
		req.addHeader("User-Agent", Server.userAgent);
		req.cnxTimeout = 12;  // recommended by AcessoCard

		var requestData = haxe.Json.stringify(params);
		req.setPostData(requestData);

		var statusCode = null;
		var t0 = Sys.time();
		req.onStatus = function (code) statusCode = code;
		req.onError = function (msg) {
			var t1 = Sys.time();
			trace(ERR + 'acesso: call failed with $msg ($statusCode) after ${Math.round((t1 - t0)*1e3)} ms');
			var err = TransportError(msg);
			log.responseCode = statusCode;
			log.responseData = Std.string(err);  // fixed behavior since in use by the health check api
			log.timing = t1 - t0;
			log.update();
			throw err;
		}
		req.onData = function (responseData) {
			var t1 = Sys.time();
			trace('acesso: got $statusCode after ${Math.round((t1 - t0)*1e3)} ms');
			log.responseCode = statusCode;
			log.responseData = responseData;
			log.timing = t1 - t0;
			log.update();
			ret = haxe.Json.parse(responseData);
			assert(ret != null && ret.ResultCode != null, statusCode,
					Type.enumConstructor(Type.typeof(ret)), "unexpected message structure");
		}

		log.requestPayload = requestData;
		log.insert();

		trace('acesso: call $url (log id ${log.id})');
		req.request(true);
		return ret;
	}
}

