%option noyywrap
%{
#include<stdio.h>
#include <string.h>
//#include"1605072_symboltable.h"


int line_no=1;
int error_no=0;


FILE *logout;
FILE *tokenout;

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
relop "=="|"!="|"<"|"<="|">"|">="
addop "+"|"-"
mulop "*"|"/"|"%"
incop "++"|"--"
assign "="
logic "&&"|"||"
bit "&"|"|"|"^"|"<<"|">>"

float1 {DIGIT}*(\.{DIGIT}+)(E[+-]?{DIGIT}+)
float2 {DIGIT}*(\.{DIGIT}+)
float {float1}|{float2}

Ill_num ({DIGIT}+)(E[+-]?{DIGIT}+)(\.{DIGIT}+)
Too_many {DIGIT}*(\.{DIGIT}+)*

Identifier [_a-zA-Z][_a-zA-Z0-9]*
WrongId [0-9][_a-zA-Z0-9]*

char [!-~]{-}['\\]
CHAR1 \'{char}\'
CHAR2 \'(\\[ntafrbv0(\\)])\'

CHAR3 \'{char}
CHAR4 \'(\\[ntafrbv0(\\)])
CHAR5 \'(\\)\'

un_char {CHAR3}|{CHAR4}|{CHAR5}

multi_char \'({char}+)\'


multiline \\[\n]
e [ -~]{-}["\n]
String \"({e}|{multiline})*\"


c [ -~]{-}[']
singlecomment1 ("//")({c}+)$
singlecomment2 ("//")({c}+){multiline}({c}+)$ 

d [ -~]{-}[*]
multicomment ("/*")([\n]|("*"[^/])|{d})*("*/")

NEWLINE \n

%%
{NEWLINE}      {
			line_no++;
		}


"if"  {
			fprintf(tokenout,"<IF>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s 				found\n",line_no,yytext);
       }

"for" {
			fprintf(tokenout,"<FOR>");
			fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s 				found\n",line_no,yytext);
       }

"do" {
			fprintf(tokenout,"<DO>");
			fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s 				found\n",line_no,yytext);
       }

"int" {
			fprintf(tokenout,"<INT>");
			fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s 				found\n",line_no,yytext);
       }

"float" {
			fprintf(tokenout,"<FLOAT>");
			fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s 				found\n",line_no,yytext);
       }

"void" {
			fprintf(tokenout,"<VOID>");
			fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s 				found\n",line_no,yytext);
       }

"switch" {
			fprintf(tokenout,"<SWITCH>");
			fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s 				found\n",line_no,yytext);
       }

"default" {
			fprintf(tokenout,"<DEFAULT>");
			fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s 				found\n",line_no,yytext);
       }
"else" {
			fprintf(tokenout,"<ELSE>");
			fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s 				found\n",line_no,yytext);
       }

"while" {
			fprintf(tokenout,"<WHILE>");
			fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s 				found\n",line_no,yytext);
       }

"break" {
			fprintf(tokenout,"<BREAK>");
			fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s 				found\n",line_no,yytext);
       }

"char" {
			fprintf(tokenout,"<CHAR>");
			fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s 				found\n",line_no,yytext);
       }

"double" {
			fprintf(tokenout,"<DOUBLE>");
			fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s 				found\n",line_no,yytext);
       }

"return" {
			fprintf(tokenout,"<RETURN>");
			fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s 				found\n",line_no,yytext);
       }

"case" {
			fprintf(tokenout,"<CASE>");
			fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s 				found\n",line_no,yytext);
       }

"continue" {
			fprintf(tokenout,"<CONTINUE>");
			fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s 				found\n",line_no,yytext);
       }
{DIGIT}+ {
			fprintf(tokenout,"<CONST_INT, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_no,yytext);
				

	}

{float}  {
			fprintf(tokenout,"<CONST_FLOAT, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_no,yytext);
						
	}

{Ill_num} {						
												  				fprintf(logout,"Error at Line No.%d:  Ill formed number %s \n",line_no,yytext);
			error_no++;

	}


{Too_many} {
															   				fprintf(logout,"Error at Line No.%d:  Too many decimal point %s \n",line_no,yytext);
																			  				error_no++;
	}

{CHAR1} {
												 				fprintf(tokenout,"<CONST_CHAR, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_no,yytext);
						
	}

{CHAR2} {
								 		  				fprintf(tokenout,"<CONST_CHAR, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_no,yytext);
						
	}

{un_char} {
						
			fprintf(logout,"Error at Line No.%d: Unfinished Character Sequence found %s \n",line_no,yytext);
			error_no++;
	}

{multi_char} {
						
			fprintf(logout,"Error at Line No.%d: Multiple Character Sequence found %s \n",line_no,yytext);
			error_no++;
						

	}	

{Identifier} {
								  		    		fprintf(tokenout,"<ID, %s>",yytext);
										   				fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n",line_no,yytext);
							
	}

{WrongId} {
										   				fprintf(logout,"Error at Line No.%d:  Invalid Identifier %s \n",line_no,yytext);
			error_no++;

	}


{relop} {
			fprintf(tokenout,"<RELOP, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",line_no,yytext);
	}

{addop} {
			fprintf(tokenout,"<ADDOP, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_no,yytext);

			
	}

{mulop} {
			fprintf(tokenout,"<MULOP, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_no,yytext);
		}

{incop} {
			fprintf(tokenout,"<INCOP, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_no,yytext);
		}
{assign} {
			fprintf(tokenout,"<ASSIGNOP, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_no,yytext);
	}

{logic} {
			fprintf(tokenout,"<LOGICOP, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n",line_no,yytext);
	}

{bit} {
			fprintf(tokenout,"<BITOP, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n",line_no,yytext);
					
	}

"!" {
			fprintf(tokenout,"<NOT, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n",line_no,yytext);
			
    }

"(" {
			fprintf(tokenout,"<LPAREN, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",line_no,yytext);
			
		}

")" {
			fprintf(tokenout,"<RPAREN, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",line_no,yytext);
		
	}

"{" {
			fprintf(tokenout,"<LCURL, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n",line_no,yytext);
			
	}

"}" {
			fprintf(tokenout,"<RCURL, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",line_no,yytext);
			
	}

"[" {
			fprintf(tokenout,"<LTHIRD, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_no,yytext);
			
    }

"]" {
			fprintf(tokenout,"<RTHIRD, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_no,yytext);
			
      }

"," {
			fprintf(tokenout,"<COMMA, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",line_no,yytext);
			
	}

";" {
			fprintf(tokenout,"<SEMICOLON, %s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_no,yytext);
			
	}

{String}  {
			fprintf(tokenout,"<STRING>");
			fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme found\n",line_no);
			
		}



{singlecomment1} {
			fprintf(tokenout,"<COMMENT>");
			fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme found\n",line_no);
			
		} 

{singlecomment2} {
			fprintf(tokenout,"<COMMENT>");
			fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme found\n",line_no);
			
		} 

{multicomment} {
			fprintf(tokenout,"<COMMENT>");
			fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme found\n",line_no);
			
		} 


%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1605072_log.txt","w");
	tokenout= fopen("1605072_token.txt","w");

	yyin= fin;
	yylex();
 fprintf(logout,"\nTotal Lines : %d\nTotal Errors : %d\n",line_no,error_no);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
