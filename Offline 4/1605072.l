
%{
#include<bits/stdc++.h>
#include<stdio.h>
#include<string.h>
#include "1605072_symboltable.h"
#define YYSTYPE SymbolInfo*
#include "y.tab.h"


using namespace std;

extern YYSTYPE yylval;
extern SymbolTable *table;
void yyerror(char *);

int line_no=1;
int error=0;


//SymbolTable s(10);


//FILE *logout;
//FILE *tokenout;

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
relop "=="|"!="|"<"|"<="|">"|">="
addop "+"|"-"
mulop "*"|"/"|"%"

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
"println"  {
				return PRINTLN;
       	   }

"if" {
		return IF;
       }

"for" {
		return FOR;
       }

"do" {
		return DO;	
       }

"int" {
		return INT;
       }

"float" {
		return FLOAT;
       }

"void" {
		return VOID;
       }

"switch" {
		return SWITCH;
       }

"default" {
		return DEFAULT;
       }
"else" {
		return ELSE;
       }

"while" {
		return WHILE;
       }

"break" {
		return BREAK;
       }

"char" {
		return CHAR;
       }

"double" {
		return DOUBLE;
       }

"return" {
		return RETURN;
       }

"case" {
		return CASE;
       }

"continue" {
		return CONTINUE;
       }
	

{relop} {
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RELOP");
		yylval = (YYSTYPE)s;
		return RELOP;
	}

{addop} {
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ADDOP");
		yylval = (YYSTYPE)s;
		return ADDOP;
			
	}

{mulop} {
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"MULOP");
		yylval = (YYSTYPE)s;
		return MULOP;
	}

"++" 	{return INCOP;}
"--" 	{return DECOP;}
"=" 	{return ASSIGNOP;}


{logic} {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LOGICOP");
			yylval = (YYSTYPE)s;
			return LOGICOP;
	}

{bit} {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"BITOP");
			yylval = (YYSTYPE)s;
			return BITOP;		
	}
{DIGIT}+ {
			SymbolInfo *s= new  SymbolInfo(yytext, (char  *)"CONST_INT");
			yylval = (YYSTYPE)s;
			return CONST_INT;

	}

{float}  {
		      SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_FLOAT");
			yylval = (YYSTYPE)s;
			return CONST_FLOAT; 
						
	}

{Identifier} {
								  		    				SymbolInfo *s= table->lookup(yytext);
				if(s==NULL)
				{					
					s= new SymbolInfo(yytext, "ID");
						//cout<<"if er vitor"<<endl;
				}
				yylval = (YYSTYPE)s;
					//cout<<"if er baire"<<endl;		
				return ID;					
	      }



"!"		{	return NOT; }

"(" 	{return LPAREN;}
")" 	{return RPAREN;}

"{" 	{return LCURL;}
"}" 	{return RCURL;}

"[" 	{return LTHIRD;}
"]" 	{return RTHIRD;}

";" 	{ return SEMICOLON;}
"," 	{return COMMA;}



%%

int yywrap()
{
	return 1;
}



