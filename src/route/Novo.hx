package route;
import Sys;
import eweb.Dispatch;
import eweb.Web;
import haxe.Json;

typedef PersonalData = {
	Bairro:String,
	CEP:String,
	Cidade:String,
	CodCliente:String,
	DDD:Int,
	DDI:Int,
	DtExpedicao:String,
	DtNascimento:String,
	Email:String,
	Logradouro:String,
	NomeCompleto:String,
	NomeMae:String,
	NumDocumento:String,
	NumeroRes:Int,
	NumeroTel:String,
	PaisOrgao:String,
	TpCliente:String,
	TpDocumento:Int,
	TpEndereco:Int,
	TpSexo:Int,
	TpTelefone:Int,
	UF:String,
	UFOrgao:String,
	?Complemento:String,
	?OrgaoExpedidor:String
}  


class Novo {
	static inline var CARD_COOKIE = "CARD_REQUEST";

	static inline var RECAPTCHA_SECRET = "6LeA3zoUAAAAAHVQxT3Xh1nILlXPjGRl83F_Q5b6";
	static inline var RECAPTCHA_URL = "https://www.google.com/recaptcha/api/siteverify";


	public function new() {}

	public function getDefault()
	{
		Web.setReturnCode(200);
		Sys.println(views.Base.render("Peça seu cartão", views.Login.render));
	}

	public function postDefault(args:{ belNumber:Int, cpf:String})
	{
		show(args);
		var recaptcha = Web.getParams().get("g-recaptcha-response");
		
		//TODO: Write a nice message..for a bot =)
		if(!recapChallenge(recaptcha))
		{
			Web.redirect("/");
			return;
		}	

		// FIXME replace with check for belNumber and cpf|name match
		var user = db.BelUser.manager.select($belNumber == args.belNumber);
		if (user == null) {
			user = new db.BelUser(args.belNumber);
			user.insert();
		}

		var card = db.CardRequest.manager.select($bearer == user);
		if (card == null) {
			card = new db.CardRequest(user);
			card.insert();
		}

		Web.setCookie(CARD_COOKIE, card.clientKey, DateTools.delta(Date.now(), DateTools.days(1)));
		Web.redirect(moveForward(card));
	}

	public function getDados()
	{
		var card = getCardRequest();
		if (card == null) {
			Web.redirect(moveForward(null));
			return;
		}
		
		Web.setReturnCode(200);
		
		Sys.println(views.Base.render("Entre com suas informações", views.CardReq.render.bind(null)));
	}

	public function postDados(args:PersonalData)
	{
		var card = getCardRequest();
		if (card == null) {
			Web.setReturnCode(404);
			Sys.println("Nenhum cartão encontrado");
			return;
		}
		// TODO store the data
		card.state = AwaitingBearerConfirmation;
		card.update();

		var datenow = Date.now();

		//TODO:I should diff between curObj with actual
		var d = new db.CardData();
		d.cardReq = card;
		d.CodEspecieProduto = "FOO"; //FIXME
		d.lastedit = datenow;
		d.last_update = datenow;
		d.last_check = datenow;
		
		//hm...this is a POG b/c i'm lazy 
		//(Fiels should have the same name, soo..)
		for(f in Reflect.fields(args))
		{
			//TODO: Check other fields =S
			if(f == "g-recaptcha-response")
				continue;

			//I pass dates as MM/DD/YYYY which is a nono
			if(f == 'DtNascimento' || f == 'DtExpedicao')
			{
				var split :Array<String> = Reflect.field(args, f).split('/');
				
				var p = [];
				for(s in split)
					p.push(Std.parseInt(s));

				var data = new Date(p[2], p[1]-1, p[0],0,0,0).getTime();
				Reflect.setField(d,f,data);
			}
			else
				Reflect.setField(d, f, Reflect.field(args, f));
		}

		d.insert();

		Web.redirect(moveForward(card));
	}

	public function getConfirma()
	{
		Web.setReturnCode(200);
		var card = getCardRequest();
		var data = db.CardData.manager.select($cardReq == card);
		Sys.println(views.Base.render("Confirme suas informações",views.Confirm.render.bind(data)));
	}

	public function postConfirma()
	{
		var card = getCardRequest();
		if (card == null) {
			Web.setReturnCode(404);
			Sys.println("Nenhum cartão encontrado");
			return;
		}
		card.state = Queued(SolicitarAdesaoCliente);
		card.update();
		var q = ProcessingQueue.global();
		q.addTask(new AcessoProcessor(card.clientKey).execute);  // FIXME
		Web.redirect(moveForward(card));
	}

	public function getStatus()
	{
		var card = getCardRequest();
		if (card == null) {
			Web.setReturnCode(404);
			Sys.println("Nenhum cartão encontrado");
			return;
		}

		Web.setReturnCode(200);
		Sys.println(Type.enumConstructor(card.state));
	}

	function moveForward(card:db.CardRequest):String
	{
		if (card == null)
			return "/novo";
		return switch card.state {
		case AwaitingBearerData: "/novo/dados";
		case AwaitingBearerConfirmation: "/novo/confirma";
		case _: "/novo/status";
		}
	}

	function getCardRequest()
	{
		var key = Web.getCookies().get(CARD_COOKIE);
		if (key == null)
			return null;
		return db.CardRequest.manager.select($clientKey == key);
	}

	function recapChallenge(challenge : String)
	{
		var ret = false;

		var http = new haxe.Http(RECAPTCHA_URL);
		http.addParameter('secret', RECAPTCHA_SECRET);
		http.addParameter('response', challenge);
		http.addParameter('remoteip', Web.getClientIP());
		
		http.onError = function(msg : String){
			trace(msg);
			throw 'Unexpected Http error $msg';
		};
		http.onData = function(d : String)
		{
			var res = Json.parse(d);
			ret = res.success;
		};
		http.request(true);

		return ret;
	}
}

