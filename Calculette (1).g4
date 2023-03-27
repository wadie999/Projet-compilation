grammar Calculette;

@header { import java.util.*; }
@members{
	int adresse = 0; //pour gerer les adresses des variables
	int labels = 1; //pour gerer les adresses des labels

	// pour avoir une table des symboles, vous pouvez la modifier pour avoir le comportement voulu
	HashMap<String, Integer> tablesSymboles = new HashMap<String, Integer>(); //table des Symboles

	//On ajoute un nouveau label
	String getLabel() { return ""+(labels++); }
}

start: calcul EOF;  //point de depart 

calcul returns [ String code ]
@init{ $code = new String(); } // On initialise $code, pour ensuite l'utiliser comme accumulateur
@after{ System.out.println($code); }
	: (decl { $code += $decl.code; })*NEWLINE*(instruction { $code += $instruction.code; })*{ $code += " HALT\n"; }
;

finInstruction
	: (NEWLINE | ';')+
;

decl returns [ String code ]
	: TYPE IDENTIFIANT finInstruction 
	{		
		tablesSymboles.put($IDENTIFIANT.text, adresse);
		adresse= adresse+ 1;
		$code = "PUSHI " + "0" + "\n";
	}
;

instruction returns [ String code ]
	: expr finInstruction? {$code = $expr.code;}
	| bool finInstruction? {$code = $bool.code;}
	| assignation finInstruction  { $code = $assignation.code; }
	| inOut finInstruction?  { $code = $inOut.code; }
	| boucle finInstruction?  { $code = $boucle.code; }
	| bloc finInstruction?{$code = $bloc.code;}
	| finInstruction {$code="";}
;

assignation returns [ String code ]
	: IDENTIFIANT '=' expr
	{
		$code = $expr.code;
        	$code = $expr.code + "STOREG " + tablesSymboles.get($IDENTIFIANT.text) + "\n";
	}   
;

inOut returns [ String code ]
	: READ '(' IDENTIFIANT ')'
	{
		int at = tablesSymboles.get($IDENTIFIANT.text);
		$code=" READ" ;
		$code+="\n"; // new line after READ
		$code+=" STORE" + (at < 0 ? "L" : "G") +" " + at + "\n";
	}
	| WRITE '(' expr ')'
	{
		$code = $expr.code
		+ "WRITE" + "\n"
		+ "POP" + "\n";
	}
;

bloc returns[String code]
	: {$code = "";}
	'{' NEWLINE? (instruction {$code += $instruction.code + "\n";})* NEWLINE? '}'

;

cond returns[String code]
	: a=bool {$code = $a.code +"\n";}
;

boucle returns[String code]
	:'repeter' NEWLINE? instruction 'tantque(' cond ')'  
	{
	      	String debutWhile = getLabel();
		String finWhile = getLabel();

		$code = "LABEL " + debutWhile +"\n";

		$code += $cond.code;
		$code += "JUMPF " + finWhile + "\n";
		$code += $instruction.code;
		$code += "JUMP " + debutWhile+"\n";


		$code += "LABEL " + finWhile + "\n";
    	}
    	|'repeter' NEWLINE? bloc 'tantque(' cond ')'
    	{
	    	String debutWhile = getLabel();
		String finWhile = getLabel();

		$code = "LABEL " + debutWhile +"\n";

		$code += $cond.code;
		$code += "JUMPF " + finWhile + "\n";
		$code += $bloc.code;
		$code += "JUMP " + debutWhile+"\n";


		$code += "LABEL " + finWhile + "\n";
    	}
;

/*si returns[String code]
	:'si(' cond ')' NEWLINE? a = instruction 
	{
		String finIf = getLabel();
		String Else = getLabel();

		$code = $cond.code +"JUMPF " + Else +"\n";

		$code += $a.code;
		$code += "JUMP " + finIf+"\n";

		$code += "LABEL " + Else + "\n";
    	}
    	('sinon' b = instruction{$code = $b.code + "\n";})?
    	{$code += "LABEL " + finIf + "\n";}
;*/

expr returns[ String code ]
	: '(' expr ')' {$code = $expr.code;}
	| a=expr '*' b=expr {$code = $a.code + $b.code + "MUL\n";} //Normalement * n'est pas prioritaire sur /
    	| a=expr '/' b=expr {$code = $a.code + $b.code + "DIV\n";}	
    	| a=expr '+' b=expr {$code = $a.code + $b.code + "ADD\n";} //Normalement + n'est pas prioritaire sur -
    	| a=expr '-' b=expr {$code = $a.code + $b.code + "SUB\n";}    
	| ENTIER {$code = "PUSHI " + $ENTIER.text + "\n";}
	| '-' ENTIER {$code = "PUSHI 1" + "PUSHI " + $ENTIER.text + "SUB" + "\n";} //entier negatifs
	| expr '^' expr
	| a=expr '==' b=expr{$code=$a.code + $b.code + "EQUAL\n";System.out.print($code);}    // Equale
        | a=expr '<>' b=expr{$code=$a.code + $b.code + "NEQ\n";}    //different
        | a=expr '>=' b=expr{$code=$a.code + $b.code + "SUPEQ\n";}    //SUP OR EQU
        | a=expr '<=' b=expr{$code=$a.code + $b.code + "INFEQ\n";}    //INF OR EQU
        | a=expr '<' b=expr{$code=$a.code + $b.code + "INF\n";}    // INF
        | a=expr '>' b=expr{$code=$a.code + $b.code + "SUP\n";}    //SUP			
	| IDENTIFIANT { $code = "PUSHG "+ tablesSymboles.get($IDENTIFIANT.text)+"\n";}    
;

bool returns[ String code ]
	: BOOL
	{
		if($BOOL.text=="true")
			$code="PUSHI 1\n";
		else
			$code="PUSHI 0\n";
	}
	| '(' bool ')' {$code = $bool.code;}
	| a=bool'and' b=bool{$code=$a.code + $b.code + "MUL\n";}    //AND
    	| a=bool'or' b=bool{$code=$a.code + $b.code + "ADD \n PUSHI 0 \n SUP \n";}    //OR
	| 'not' BOOL
	{
        	if($BOOL.text=="true"){ $code="PUSHI 0"+"\n";} //not true correspond a 0
        	if($BOOL.text=="false"){ $code="PUSHI 1"+"\n";} //not false correspond a 1
                System.out.print($code);
        } 
	| expr {$code = $expr.code;}
;

// règles du lexer. Skip pour dire ne rien faire
TYPE : 'int' | 'float'; // pour pouvoir gérer des floats
WRITE : 'afficher';
READ : 'lire';
BOOL : ('true'|'false')+;
IDENTIFIANT
	: ('a' ..'z' | 'A' ..'Z' | '_') ('a' ..'z' | 'A' ..'Z' | '_' | '0' ..'9')*
;
NEWLINE : '\r'? '\n' -> skip;
WS : (' '|'\t')+ -> skip;
ENTIER : ('0'..'9')+;
UNMATCH : . -> skip;
