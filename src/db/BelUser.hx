package db;

@:id(belNumber)
class BelUser extends sys.db.Object {
	public var belNumber:Int;
	public var cpf:String;

	public function new(belNumber, cpf)
	{
		super();
		this.belNumber = belNumber;
		this.cpf = cpf;
	}
}

