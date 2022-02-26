%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include <limits>
#include <sstream>
#include<bits/stdc++.h>
FILE* logtext = fopen("log.txt","w");
FILE* errortext = fopen("error.txt","w");
#include "1605072_symboltable.h"
#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

FILE *fp;

vector<string> id;
vector<string> f_dec;
vector<string> p_list;
vector<string> i_dec;
vector<bool> pointer;
vector<string> var;

vector<SymbolInfo*>list1;

extern int line_no;
extern int error;

SymbolTable *table = new SymbolTable(7);

void yyerror(const char *s)
{
	//write your code
}


string int_string (int a)
{
    string str= to_string(a);  
    return str;
}

int labelCount=0;
int tempCount=0;

char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}



%}


%error-verbose

%token IF ELSE FOR WHILE DO BREAK RETURN SWITCH CASE DEFAULT CONTINUE
%token CONST_INT CONST_FLOAT CONST_CHAR INT FLOAT CHAR DOUBLE VOID
%token ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP BITOP NOT DECOP
%token STRING ID PRINTLN LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
 
%left ADDOP MULOP RELOP LOGICOP BITOP 



%nonassoc ELSE_IF
%nonassoc ELSE

%start start

%%

start : program
	{
		//write your code in this block in all the similar blocks below
		if(!f_dec.empty())
		{
		  //cout<<"Undefined functions:"<<endl;
		  for(int i=0;i<f_dec.size();i++)
		  {
		    //cout<<f_dec[i]<<endl;
			fprintf(errortext,"Error at Line %d: Undefined functions: %s\n\n",line_no,f_dec[i].c_str());
			error++;
		  }
		}
		fprintf(logtext,"\t\t Symbol Table: \n\n");
		table->printAllScopes();
		fprintf(logtext,"\nTotal Lines: %d\n\n",line_no);
		fprintf(logtext,"Total Errors: %d\n\n",error);
		fprintf(errortext,"Total Errors: %d\n\n",error);

		string x="";
		string y="";
	    x+="\n.MODEL SMALL";
		x+="\n\.STACK 100H";
		x+="\n\.DATA \n\n";
		for(int i=0;i<var.size();i++)
		{
			x+=var[i]+" dw ?\n";
		}
	
	$1->setCode(x+".CODE\n\n"+$1->getCode());

	y+="OUTDEC PROC\nPUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\n";
	y+="CMP AX,0\nJGE BEGIN\nPUSH AX \nMOV DL,'-'\nMOV AH,2\nINT 21H\nPOP AX\nNEG AX\n\n";
	y+="BEGIN:\nXOR CX,CX\nMOV BX,10\n\nREPEAT: \nXOR DX,DX \nDIV BX \nPUSH DX \nINC CX \nOR AX,AX \nJNE REPEAT \nMOV AH,2 \n\n";
	y+="PRINT_LOOP: \nPOP DX \nADD DL,30H \nINT 21H \nLOOP PRINT_LOOP \n\nMOV AH,2\nMOV DL,10\nINT 21H\n\nMOV DL,13\nINT 21H\n\n";
	y+="POP DX \nPOP CX \nPOP BX \nPOP AX \nret \nOUTDEC ENDP \nEND MAIN\n";

	$1->setCode($1->getCode()+ y);

     FILE* b= fopen("output.asm","w");
	 
	 fprintf(b,"%s",$1->getCode().c_str());
	 fclose(b);
	 b= fopen("output.asm","r");

		
	}
	;

program : program unit 
	{
        fprintf(logtext,"At Line no: %d program : program unit \n\n",line_no);
        $$=new SymbolInfo($1->getName()+$2->getName(),"program ");
        fprintf(logtext,"%s%s\n\n", $1->getName().c_str(),$2->getName().c_str());

		$$->setCode($1->getCode()+$2->getCode());

    }
	| unit
	{
        fprintf(logtext,"At Line no: %d program : unit \n\n",line_no);
        $$=new SymbolInfo($1->getName(),"program ");
        fprintf(logtext,"%s\n\n", $1->getName().c_str());

		$$->setCode($1->getCode());

	 }
	;

unit : var_declaration
     {
     fprintf(logtext,"At Line no: %d unit : var_declaration \n\n",line_no);
     $$=new SymbolInfo($1->getName()+"\n","unit ");
     fprintf(logtext,"%s\n\n", $1->getName().c_str());

	 $$->setCode($1->getCode());

     }
     | func_declaration
     {
     fprintf(logtext,"At Line no: %d unit : func_declaration \n\n",line_no);
     $$=new SymbolInfo($1->getName()+"\n","unit ");
     fprintf(logtext,"%s\n\n", $1->getName().c_str());

		$$->setCode($1->getCode());

     }
     | func_definition
     {
     fprintf(logtext,"At Line no: %d unit : func_definition \n\n",line_no);
     $$=new SymbolInfo($1->getName()+"\n","unit ");
     fprintf(logtext,"%s\n\n", $1->getName().c_str());
	 
		$$->setCode($1->getCode());

     }
     ;

func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
		{
  fprintf(logtext,"At Line no: %d func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n",line_no);
  $$=new SymbolInfo($1->getName()+" "+$2->getName()+"("+$4->getName()+")"+$6->getName(),"func_definition");
  table->insert($2->getName(),"ID");
  fprintf(logtext,"%s %s(%s)%s\n\n", $1->getName().c_str(),$2->getName().c_str(),$4->getName().c_str(),$6->getName().c_str());
		 auto it=f_dec.begin();
		    for(int i=0;i<f_dec.size();i++)
			{
				if($2->getName() == f_dec[i])
				{
				  f_dec.erase(it+i);
				  break;
				}
			}
			var.push_back($2->getName()+"_return");

			$$->setCode($2->getName()+" PROC\n");								
			if($2->getName()=="main"){
				$$->setCode($$->getCode()+"MOV AX,@DATA\nMOV DS,AX\n"+$6->getCode()+"LReturn"+$2->getName()+":\nMOV AH,4CH\nINT 21H\n");
			}
			else
			{
				$$->setCode($2->getName()+" ENDP\n");
			}
			
		 }
		| type_specifier ID LPAREN RPAREN compound_statement
		{
fprintf(logtext,"At Line no: %d func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n",line_no);
  $$=new SymbolInfo($1->getName()+" "+$2->getName()+"("+")"+$5->getName(),"func_definition");
  table->insert($2->getName(),"ID");
fprintf(logtext,"%s %s()%s\n\n", $1->getName().c_str(),$2->getName().c_str(),$5->getName().c_str());
		 auto it=f_dec.begin();
		 for(int i=0;i<f_dec.size();i++)
			{
				if($2->getName() == f_dec[i])
				{
				  f_dec.erase(it+i);
				  break;
				}
			}

			var.push_back($2->getName()+"_return");
			$1->setName($1->getName()+" "+$2->getName()+"()");

			$$->setCode($2->getName()+" PROC\n");
											
			if($2->getName()=="main"){
				$$->setCode($$->getCode()+"MOV AX,@DATA\nMOV DS,AX\n"+$5->getCode()+"LReturn"+$2->getName()+":\nMOV AH,4CH\nINT 21H\n");
			}
			else
			{
				$$->setCode($2->getName()+" ENDP\n");	
			}
											
			
		 }
 		;

compound_statement : LCURL {
					table->enter_scope();
				//cout<<"size of i_dec : "<<i_dec.size()<<endl;

				for(int i=0;i<i_dec.size();i++)
				{	
					table->insert(p_list[i],"ID");
					SymbolInfo* ss= table->lookup(p_list[i]);
					if(ss!=NULL)
					{
						ss->tt=i_dec[i];
						//cout<<"i_dec : "<<i_dec[i]<<"tt dec: "<<ss->tt<<endl;
					}
				}

				p_list.clear();
				i_dec.clear();
			}
			statements RCURL{
	   fprintf(logtext,"At Line no: %d compound_statement : LCURL statements RCURL \n\n",line_no);
                   $$=new SymbolInfo("{\n"+$3->getName()+"\n}","compound_statement");
                   fprintf(logtext,"{%s}\n\n",$3->getName().c_str());
				for(int i=0;i<id.size();i++)
			{
				if(table->lookup(id[i])==NULL)
					table->insert(id[i],"ID");
				
			}
			id.clear();

			$$->setCode($3->getCode());

			table->printAllScopes();
			table->exit_scope();
       		 }
		   | LCURL RCURL
		   {
                   fprintf(logtext,"At Line no: %d compound_statement : LCURL RCURL \n\n",line_no);
                   $$=new SymbolInfo("{}","compound_statement");
                   fprintf(logtext,"{}\n\n");
			for(int i=0;i<id.size();i++)
			{
				if(table->lookup(id[i])==NULL)
					table->insert(id[i],"ID");
				
			}
			id.clear();
			p_list.clear();
			i_dec.clear();
			table->printAllScopes();
			table->exit_scope();
       		   }
 		   ;

statements : statement
	   {
            fprintf(logtext,"At Line no: %d statements : statement \n\n",line_no);
            $$=new SymbolInfo($1->getName(),"statements ");
            fprintf(logtext," %s\n\n", $1->getName().c_str());
			$$->setCode($1->getCode());
           }
	   | statements statement
	   {
            fprintf(logtext,"At Line no: %d statements : statements statement \n\n",line_no);
            $$=new SymbolInfo($1->getName()+"\n"+$2->getName(),"statements ");
            fprintf(logtext,"%s\n%s\n\n", $1->getName().c_str(),$2->getName().c_str());
        
			$$->setCode($1->getCode()+$2->getCode());

		}
	   ;

statement : var_declaration
	  {
	     fprintf(logtext,"At Line no: %d statement : var_declaration\n\n",line_no);
	     $$=new SymbolInfo($1->getName(),"statement ");
	     fprintf(logtext,"%s\n\n", $1->getName().c_str());
          }
	  | compound_statement
	  {
	     fprintf(logtext,"At Line no: %d statement : compound_statement\n\n",line_no);
	     $$=new SymbolInfo($1->getName(),"statement ");
	     fprintf(logtext,"%s\n\n", $1->getName().c_str());
		 $$->setCode($1->getCode());
          }
	  | expression_statement
	  {
	     fprintf(logtext,"At Line no: %d statement : expression_statement\n\n",line_no);
	     $$=new SymbolInfo($1->getName(),"statement ");
	     fprintf(logtext,"%s\n\n", $1->getName().c_str());
		 $$->setCode($1->getCode());
          }
	  | RETURN expression SEMICOLON
	  {
          fprintf(logtext,"At Line no: %d statement : RETURN expression SEMICOLON\n\n",line_no);
	      $$=new SymbolInfo("return "+$2->getName()+";","statement");
          fprintf(logtext,"return %s;\n\n", $2->getName().c_str());

			/*pqr */
		    string x="";
			x+=$2->getCode();
			x+="mov ax,"+$2->getId();
			x+="\n";
			$$->setCode(x);

          }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
        fprintf(logtext,"At Line no: %d statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",line_no);
	    $$=new SymbolInfo("for("+$3->getName()+$4->getName()+$5->getName()+")"+$7->getName(),"statement");
		fprintf(logtext,"for(%s%s%s)%s\n\n", $3->getName().c_str(),$4->getName().c_str(),$5->getName().c_str(),$7->getName().c_str());
		
		/*pqr */

		char *lab1=newLabel();
		char *lab2=newLabel();
		string x="";
		x+=$3->getCode()+string(lab1)+":\n"+$4->getCode();
		x+="mov ax,"+$4->getId()+"\n";
		x+="cmp ax,0\n";
		x+="JE "+string(lab2)+"\n";
		x+=$7->getCode()+$5->getCode();
		x+="JMP "+string(lab1)+"\n";
		x+=string(lab2)+":\n";

		$$->setCode(x);

    }
	  | IF LPAREN expression RPAREN statement %prec ELSE_IF
	  {
           fprintf(logtext,"At Line no: %d statement : IF LPAREN expression RPAREN statement \n\n",line_no);
	       $$=new SymbolInfo("if("+$3->getName()+")"+$5->getName(),"statement");
           fprintf(logtext,"if(%s)%s\n\n", $3->getName().c_str(),$5->getName().c_str());
		
		   /*pqr */
			char *lab=newLabel();

			string x="";
			x+=$3->getCode();
			x+="mov ax,"+$3->getId()+"\n";
			x+="cmp ax,0\n";
			x+="JE "+string(lab)+"\n";
			x+=$5->getCode()+string(lab)+":\n";

			$$->setCode(x);

      }
	  | IF LPAREN expression RPAREN statement ELSE statement
	   {
      fprintf(logtext,"At Line no: %d statement : IF LPAREN expression RPAREN statement ELSE statement \n\n",line_no);
	  $$=new SymbolInfo("if("+$3->getName()+")"+$5->getName()+"ELSE"+$7->getName(),"statement");
      fprintf(logtext,"if(%s)%s else %s\n\n", $3->getName().c_str(),$5->getName().c_str());
      
	  
		/*pqr */

		char *lab1=newLabel();
		char *lab2=newLabel();

		string x="";
		x+=$3->getCode();
		x+="mov ax,"+$3->getId()+"\n";
		x+="cmp ax,0\n";
		x+="JE "+string(lab1)+"\n";
		x+=$5->getCode();
		x+="JMP "+string(lab2)+"\n";
		x+=string(lab1)+":\n";
		x+=$7->getCode()+string(lab2)+":\n";

		$$->setCode(x);
	  
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
      fprintf(logtext,"At Line no: %d statement : WHILE LPAREN expression RPAREN statement \n\n",line_no);
	  $$=new SymbolInfo("while("+$3->getName()+")"+$5->getName(),"statement");
      fprintf(logtext,"while(%s)%s \n\n", $3->getName().c_str(),$5->getName().c_str());
      
	    /*pqr */

		char *lab1=newLabel();
		char *lab2=newLabel();

		string x="";
		x+=string(lab1)+":\n";
		x+=$3->getCode();
		x+="mov ax,"+$3->getId()+"\n";
		x+="cmp ax,0\n";
		x+="JE "+string(lab2)+"\n";
		x+=$5->getCode()+"JMP "+string(lab1)+"\n";
		x+=string(lab2)+":\n";
		
		$$->setCode(x);
	  
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
      fprintf(logtext,"At Line no: %d statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n\n",line_no);
	  $$=new SymbolInfo("println("+$3->getName()+");","statement");
      fprintf(logtext,"println(%s); \n\n", $3->getName().c_str());
      
	  string x="";
	  x+="mov ax,"+$3->getName()+int_string(table->look_scope_id($3->getName()));
	  x+="\nCALL OUTDEC\n";
	  $$->setCode(x); 

	  }
	  ;

expression_statement 	: SEMICOLON
			            {
						fprintf(logtext,"At Line no: %d expression_statement 	: SEMICOLON\n\n",line_no);
						$$=new SymbolInfo($1->getName(),"expression_statement ");
						fprintf(logtext,";\n\n", $1->getName().c_str());
                        }			
			| expression SEMICOLON
			{
                     fprintf(logtext,"At Line no: %d expression_statement : expression SEMICOLON\n\n",line_no);
		             $$=new SymbolInfo($1->getName()+";","expression_statement");
		             fprintf(logtext,"%s;\n\n", $1->getName().c_str());
		    
					 $$->setCode($1->getCode());
					 $$->setId($1->getId());
			
			} 
			;

expression : logic_expression	
	   {
	     fprintf(logtext,"At Line no: %d expression : logic_expression\n\n",line_no);
	     $$=new SymbolInfo($1->getName(),"expression ");
	     fprintf(logtext,"%s\n\n", $1->getName().c_str());
		 $$->tt=$1->tt;

		 $$->setCode($1->getCode());
		 $$->setId($1->getId());

       }
	   | variable ASSIGNOP logic_expression
	   {
           fprintf(logtext,"At Line no: %d expression : variable ASSIGNOP logic_expression\n\n",line_no);
	       $$=new SymbolInfo($1->getName()+"="+$3->getName(),"expression");
           fprintf(logtext,"%s=%s\n\n", $1->getName().c_str(),$3->getName().c_str());
		   if($1->tt == "CONST_FLOAT"&& $3->tt=="CONST_INT"){}
			else if($1->tt != $3->tt )
			{
				//fprintf(errortext,"%s = %s\n\n", $1->tt.c_str(),$3->tt.c_str());
				fprintf(errortext,"Error at Line %d: Type Mismatch\n\n", line_no);
		         error++;
				 
			}

			string x=$1->getCode()+$3->getCode();
			
			x+="mov ax,"+$3->getId()+"\n";
			cout<<$1->getName()<<"\t"<<$1->get_arr()<<"\n";
			if($1->get_arr()==0)
			{
			x+="mov "+$1->getId()+",ax\n";
			cout<<"not array";
			}
			else
			{
				cout<<"array";
			x+="mov "+$1->getId()+"[bx],ax\n";
			}
			
			$$->setId($1->getId());
			$$->setCode(x);
        }  	
	   ;

logic_expression : rel_expression
		 {
	         fprintf(logtext,"At Line no: %d logic_expression : rel_expression\n\n",line_no);
	         $$=new SymbolInfo($1->getName(),"logic_expression");
	         fprintf(logtext,"%s\n\n", $1->getName().c_str());
			 $$->tt=$1->tt;

			 $$->setCode($1->getCode());
			 $$->setId($1->getId());

         }	 	
		 | rel_expression LOGICOP rel_expression
		 {
             fprintf(logtext,"At Line no: %d logic_expression : rel_expression LOGICOP rel_expression\n\n",line_no);
	         $$=new SymbolInfo($1->getName()+" "+$2->getName()+" "+$3->getName(),"logic_expression");
             fprintf(logtext,"%s %s %s\n\n", $1->getName().c_str(),$2->getName().c_str(),$3->getName().c_str());
             $$->tt="CONST_INT";

			 
					char *lab1=newLabel();
					char *lab2=newLabel();
					char *lab3=newLabel();
					char *t=newTemp();
				string x=$1->getCode()+$3->getCode();
			
			if($2->getName()=="&&")
			{
				
				
				x+="mov ax,"+$1->getId()+"\n";
				x+="cmp ax,0\n";
				x+="JE "+string(lab2)+"\n";
				x+="mov ax,"+$3->getId()+"\n";
				x+="cmp ax,0\n";
				x+="JE "+string(lab2)+"\n"+string(lab1)+":\n";
				x+="mov "+string(t)+",1\n";
				x+="JMP "+string(lab3)+"\n"+string(lab2)+":\n";
				x+="mov "+string(t)+",0\n"+string(lab3)+":\n";
				

			}

			else if($2->getName()=="||")
			{
				
				
				x+="mov ax,"+$1->getId()+"\n";
				x+="cmp ax,0\n";
				x+="JNE "+string(lab2)+"\n";
				x+="mov ax,"+$3->getId()+"\n";
				x+="cmp ax,0\n";
				x+="JNE "+string(lab2)+"\n"+string(lab1)+":\n";
				x+="mov "+string(t)+",0\n";
				x+="JMP "+string(lab3)+"\n"+string(lab2)+":\n";
				x+="mov "+string(t)+",1\n"+string(lab3)+":\n";
				

			}
			$$->setCode(x);
			$$->setId(t);
			var.push_back(t);

        } 	
		 ;

rel_expression	: simple_expression 
		   {
	         fprintf(logtext,"At Line no: %d rel_expression : simple_expression \n\n",line_no);
	         $$=new SymbolInfo($1->getName(),"rel_expression");
	         fprintf(logtext,"%s\n\n", $1->getName().c_str());
			 $$->tt=$1->tt;

			$$->setCode($1->getCode());
			$$->setId($1->getId());

           }
		| simple_expression RELOP simple_expression
		{
             fprintf(logtext,"At Line no: %d rel_expression : simple_expression RELOP simple_expression\n\n",line_no);
	         $$=new SymbolInfo($1->getName()+" "+$2->getName()+" "+$3->getName(),"rel_expression");
             fprintf(logtext,"%s %s %s\n\n", $1->getName().c_str(),$2->getName().c_str(),$3->getName().c_str());
             $$->tt="CONST_INT";

			
			char *t=newTemp();
			char *lab1=newLabel();
			char *lab2=newLabel();

			string x=$1->getCode()+$3->getCode();

			x+="mov ax,"+$1->getId()+"\n";
			x+="cmp ax,"+$3->getId()+"\n";
			if($2->getName()=="<")
			{
				x+="JL "+string(lab1)+"\n";

			}
			else if($2->getName()==">")
			{
				x+="JG "+string(lab1)+"\n";

			}
			else if($2->getName()=="==")
			{
				x+="JE "+string(lab1)+"\n";

			}
			else if($2->getName()=="!=")
			{
				x+="JNE "+string(lab1)+"\n";

			}
			else if($2->getName()==">=")
			{
				x+="JGE "+string(lab1)+"\n";

			}
			else if($2->getName()=="<=")
			{
				x+="JLE "+string(lab1)+"\n";

			}
			
			x+="mov "+string(t)+",0\n";
			x+="JMP "+string(lab2)+"\n"+string(lab1)+":\n";
			x+="mov "+string(t)+",1\n"+string(lab2)+":\n";

			var.push_back(t);
			$$->setCode(x);
			$$->setId(t);


        } 	
		;

simple_expression : term 
		  {
	          fprintf(logtext,"At Line no: %d simple_expression : term  \n\n",line_no);
	          $$=new SymbolInfo($1->getName(),"simple_expression");
	          fprintf(logtext,"%s\n\n", $1->getName().c_str());
			  $$->tt=$1->tt;
			  $$->setCode($1->getCode());
			  $$->setId($1->getId());

          }
		  | simple_expression ADDOP term 
		  {
  fprintf(logtext,"At Line no: %d simple_expression : simple_expression ADDOP term\n\n",line_no);
	         $$=new SymbolInfo($1->getName()+" "+$2->getName()+" "+$3->getName(),"simple_expression");
fprintf(logtext,"%s %s %s\n\n", $1->getName().c_str(),$2->getName().c_str(),$3->getName().c_str());
if(($1->tt=="CONST_INT" && $3->tt=="CONST_FLOAT")||($1->tt=="CONST_FLOAT" && $3->tt=="CONST_INT")||($1->tt=="CONST_FLOAT" && $3->tt=="CONST_FLOAT"))
		{
		  $$->tt="CONST_FLOAT";
		}
		else $$->tt="CONST_INT";

		string x = $1->getCode()+$3->getCode();
		x=x+"mov ax,"+$1->getId()+"\n";

		char *t=newTemp();
		if($2->getName()=="+")
		{
			x=x+"add ax,"+$3->getId()+"\n";
		}
		else
		{
			x=x+"sub ax,"+$3->getId()+"\n";
		}
		x=x+"mov "+string(t)+",ax\n";
		$$->setCode(x);
		$$->setId(t);
		var.push_back(t);

        } 

		 ;

term :	unary_expression
     {
     fprintf(logtext,"At Line no: %d term : unary_expression  \n\n",line_no);
     $$=new SymbolInfo($1->getName(),"term");
     fprintf(logtext,"%s\n\n", $1->getName().c_str());
	 $$->tt=$1->tt;

	 $$->setCode($1->getCode());
	 $$->setId($1->getId());

     }
     |  term MULOP unary_expression
     {
  fprintf(logtext,"At Line no: %d term : term MULOP unary_expression\n\n",line_no);
	         $$=new SymbolInfo($1->getName()+" "+$2->getName()+" "+$3->getName(),"term");
  fprintf(logtext,"%s %s %s\n\n", $1->getName().c_str(),$2->getName().c_str(),$3->getName().c_str());
  ////cout<<"dollar checka kori"<<$1->tt<<$3->tt<<endl;
	if($2->getName()=="%")
	{
		if(($1->tt=="CONST_INT" && $3->tt=="CONST_FLOAT")||($1->tt=="CONST_FLOAT" && $3->tt=="CONST_INT")||($1->tt=="CONST_FLOAT" && $3->tt=="CONST_FLOAT"))
		{
		  fprintf(errortext,"Error at Line %d: Integer operand on modulus operator\n\n", line_no);
		 error++;
		}
	 $$->tt="CONST_INT";

	 
	 char *t=newTemp();
	 string x =$1->getCode()+$3->getCode();
	 x=x+"mov ax,"+$1->getId()+"\n";
	 x=x+"mov bx,"+$3->getId()+"\n";
	 x=x+"mov dx,0\n";
	 x=x+"div bx\n";
	 x=x+"mov "+string(t)+",dx\n";

	 $$->setCode(x);
	 $$->setId(t);
	 var.push_back(t);

	}
	else{
		if(($1->tt=="CONST_INT" && $3->tt=="CONST_FLOAT")||($1->tt=="CONST_FLOAT" && $3->tt=="CONST_INT")||($1->tt=="CONST_FLOAT" && $3->tt=="CONST_FLOAT"))
		{
		  $$->tt="CONST_FLOAT";
		}
		else $$->tt="CONST_INT";

		if($2->getName()=="/"){

				
				char *t=newTemp();
				string x =$1->getCode()+$3->getCode();
				x=x+"mov ax,"+$1->getId()+"\n";
				x=x+"mov bx,"+$3->getId()+"\n";
				//x=x+"   mov dx,0";
				x=x+"div bx\n";
				x=x+"mov "+string(t)+",ax\n";

				$$->setCode(x);
				$$->setId(t);
				var.push_back(t);
		}
		else
		{
			
			char *t=newTemp();
			string x =$1->getCode()+$3->getCode();
			x=x+"mov ax,"+$1->getId()+"\n";
			x=x+"mov bx,"+$3->getId()+"\n";
			//x=x+"   mov dx,0";
			x=x+"mul bx\n";
			x=x+"mov "+string(t)+",ax\n";

			$$->setCode(x);
			$$->setId(t);
			var.push_back(t);

		}
		

	}
     } 
     ;

unary_expression : factor 
		 {
	         fprintf(logtext,"At Line no: %d unary_expression : factor \n\n",line_no);
	         $$=new SymbolInfo($1->getName(),"unary_expression ");
	         fprintf(logtext,"%s\n\n", $1->getName().c_str());
			 $$->tt=$1->tt;
			 $$->setCode($1->getCode());
				$$->setId($1->getId());
	         }
		 | ADDOP unary_expression 
		 {
             fprintf(logtext,"At Line no: %d unary_expression : ADDOP unary_expression\n\n",line_no);
	         $$=new SymbolInfo($1->getName()+" "+$2->getName(),"unary_expression");
             fprintf(logtext,"%s %s\n\n", $1->getName().c_str(),$2->getName().c_str());
             $$->tt=$2->tt;

			string x=$2->getCode();
			if($1->getName()=="-"){
				x+="mov ax,"+$2->getId()+"\n";
				x+="NEG ax\n";
				x+="mov "+$2->getId()+",ax\n";

            }
			$$->setCode(x);
			$$->setId($2->getId());

         }  
		 | NOT unary_expression
		 {
            
			 fprintf(logtext,"At Line no: %d unary_expression : NOT unary_expression\n\n",line_no);
	         $$=new SymbolInfo("!"+$2->getName(),"unary_expression");
             fprintf(logtext,"!%s\n\n", $2->getName().c_str());
             $$->tt="CONST_INT";

             string x=$2->getCode();
             x+="mov ax,"+$2->getId()+"\n";
             x+="NOT ax\n";
             x+="mov "+$2->getId()+",ax\n";

             $$->setCode(x);
             $$->setId($2->getId());


          }  
		 ;

factor	: variable 
	{
         fprintf(logtext,"At Line no: %d factor : variable \n\n",line_no);
         $$=new SymbolInfo($1->getName(),"factor");
         fprintf(logtext,"%s\n\n", $1->getName().c_str());
		 $$->tt=$1->tt;
		 string x=$1->getCode();

		 if($1->get_arr()==1)
		 {
			 char *t=newTemp();
			 cout<<"array1";
			x+="mov ax,"+$1->getId()+"[bx]\n";
			x+="mov "+string(t)+",ax\n";
			var.push_back(t);
			$$->setId(t);
		 }
		else
		{
			cout<<"not array1";
			$$->setId($1->getId());
		}
		
		 $$->setCode(x);
        }
	| CONST_INT
	{
         fprintf(logtext,"At Line no: %d factor : CONST_INT \n\n",line_no);
         $$=new SymbolInfo($1->getName(),"factor");
         fprintf(logtext,"%s\n\n", $1->getName().c_str());
		 $$->tt="CONST_INT";
		 char* tp =newTemp();
		 string x=(string)tp;
		 $$->setCode("mov "+x+","+$1->getName()+"\n");
		 $$->setId(x);
		 var.push_back(tp);
        } 
	| CONST_FLOAT
	{
         fprintf(logtext,"At Line no: %d factor : CONST_FLOAT \n\n",line_no);
         $$=new SymbolInfo($1->getName(),"factor");
         fprintf(logtext,"%s\n\n", $1->getName().c_str());
		 $$->tt="CONST_FLOAT";
		 char* tp =newTemp();
		 string x=(string)tp;
		 $$->setCode("mov "+x+","+$1->getName()+"\n");
		 $$->setId(x);
		 var.push_back(tp);
    }
        | variable INCOP 
	    {
          fprintf(logtext,"At Line no: %d factor : variable INCOP\n\n",line_no);
	         $$=new SymbolInfo($1->getName()+"++","factor");
           fprintf(logtext,"%s++\n\n", $1->getName().c_str());
		   $$->tt=$1->tt;

			char *t=newTemp();
			string x="";
			if($1->get_arr()==1){
				cout<<"array2";
				x+="mov ax,"+$1->getId()+"[bx]\n";
			}
			else
			x+="mov ax,"+$1->getId()+"\n";
			x+="mov "+string(t)+",ax\n";
			if($1->get_arr()==1){
				cout<<"array2";
				x+="mov ax,"+$1->getId()+"[bx]\n";
				x+="INC ax\n";
				x+="mov "+$1->getId()+"[bx],ax\n";
			}
			else
			x+="INC "+$1->getId()+"\n";

			var.push_back(t);

			$$->setCode(x); 
			$$->setId(t);

        } 
	| variable DECOP
	{
         fprintf(logtext,"At Line no: %d factor : variable DECOP\n\n",line_no);
	         $$=new SymbolInfo($1->getName()+"--","factor");
         fprintf(logtext,"%s--\n\n", $1->getName().c_str());
		  $$->tt=$1->tt;

		  char *t=newTemp();
			string x="";
			if($1->get_arr()==1){
				x+="mov ax,"+$1->getId()+"[bx]\n";
			}
			else
			x+="mov ax,"+$1->getId()+"\n";
			x+="mov "+string(t)+",ax\n";
			if($1->get_arr()==1){
				x+="mov ax,"+$1->getId()+"[bx]\n";
				x+="DEC ax\n";
				x+="mov "+$1->getId()+"[bx],ax\n";
			}
			else
			x+="DEC "+$1->getId()+"\n";

			var.push_back(t);

			$$->setCode(x); 
			$$->setId(t);

    } 
	| LPAREN expression RPAREN
        {
          fprintf(logtext,"At Line no: %d factor : LPAREN expression RPAREN\n\n",line_no);
	      $$=new SymbolInfo("("+$2->getName()+")","factor");
          fprintf(logtext,"(%s)\n\n", $2->getName().c_str());

		  $$->setCode($2->getCode());
		  $$->setId($2->getId());

        }
	| ID LPAREN argument_list RPAREN 
        {
          fprintf(logtext,"At Line no: %d factor : ID LPAREN argument_list RPAREN \n\n",line_no);
	      $$=new SymbolInfo($1->getName()+"("+$3->getName()+")","factor");
           fprintf(logtext,"%s(%s)\n\n", $1->getName().c_str(),$3->getName().c_str());	 


        }   
	;

argument_list : arguments
	      {
              fprintf(logtext,"At Line no: %d argument_list : arguments \n\n",line_no);
              $$=new SymbolInfo($1->getName(),"arguments");
              fprintf(logtext,"%s\n\n", $1->getName().c_str());

			  $$->setCode($1->getCode());

              }
	      |
	      {
              fprintf(logtext,"At Line no: %d argument_list : \n\n",line_no);
              $$=new SymbolInfo("","arguments");
              fprintf(logtext,"\n\n");
              }
	      ;

arguments : arguments COMMA logic_expression
	  {
          fprintf(logtext,"At Line no: %d arguments : arguments COMMA logic_expression \n\n",line_no);
	      $$=new SymbolInfo($1->getName()+","+$3->getName(),"factor");
          fprintf(logtext,"%s,%s\n\n", $1->getName().c_str(),$3->getName().c_str());
         
		  $$->setCode($1->getCode()+$3->getCode());	 
		 
	  }   
	  | logic_expression
	  {
              fprintf(logtext,"At Line no: %d arguments : logic_expression \n\n",line_no);
              $$=new SymbolInfo($1->getName(),"arguments");
              fprintf(logtext,"%s\n\n", $1->getName().c_str());
			  $$->setCode($1->getCode());
          }
	  ;

variable : ID 		
	 {
         fprintf(logtext,"At Line no: %d variable : ID \n\n",line_no);
         $$=new SymbolInfo($1->getName(),"variable");
         fprintf(logtext,"%s\n\n", $1->getName().c_str());
		 //id.push_back($1->getName());
		 if(table->lookup($1->getName())==NULL)
		 {
			fprintf(errortext,"Error at Line %d: Undeclared variable: %s\n\n", line_no,$1->getName().c_str());
			error++;
		 }
		 else
		 {
		 	SymbolInfo* ss= table->lookup($1->getName());
			$$->tt=ss->tt;

			$$->setId($1->getName()+int_string(table->look_scope_id($1->getName())));
			//cout<<"name: "<<$1->getName()<<"  tt of $$:"<< $$->tt<<endl;
		 }
		 //$$->tt = 
		 
		
     }
	 | ID LTHIRD expression RTHIRD 
	 {
          fprintf(logtext,"At Line no: %d variable : ID LTHIRD expression RTHIRD\n\n",line_no);
	  $$=new SymbolInfo($1->getName()+"["+$3->getName()+"]","variable");
  fprintf(logtext,"%s[%s]\n\n", $1->getName().c_str(),$3->getName().c_str());
		//id.push_back($1->getName());
		$$->tt=$3->tt;
		//$$->set_arr("y");
		////cout<<"check kori"<<$$->tt<<endl;
		if($$->tt == "CONST_FLOAT")
		{
			fprintf(errortext,"Error at Line %d: Non-Integer Array Index \n\n", line_no);
				 error++;
		}

		string x=$3->getCode();
		//x+=$3->getCode();
		x+="mov bx,"+$3->getId()+"\n";
		x+="add bx,bx\n";
		$$->setId($1->getName()+int_string(table->look_scope_id($1->getName())));
		
		$$->setCode(x);
		$$->set_arr(1);

     }  
	 ;

func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON
		 {
fprintf(logtext,"At Line no: %d func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n\n",line_no);
  $$=new SymbolInfo($1->getName()+" "+$2->getName()+"("+")"+";","func_declaration");
fprintf(logtext,"%s %s();\n\n", $1->getName().c_str(),$2->getName().c_str());
	//table->insert($2->getName(),"ID");
	      //f_dec.push_back($2->getName());
		    p_list.clear();
			i_dec.clear();
		 }
		 | type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		 {
fprintf(logtext,"At Line no: %d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON \n\n",line_no);
  $$=new SymbolInfo($1->getName()+" "+$2->getName()+"("+$4->getName()+")"+";","func_declaration");
fprintf(logtext,"%s %s(%s);\n\n",$1->getName().c_str(),$2->getName().c_str(),$4->getName().c_str());
		//table->insert($2->getName(),"ID");
		//f_dec.push_back($2->getName());
		    p_list.clear();
			i_dec.clear();
		 }
		 ;
parameter_list  : parameter_list COMMA type_specifier ID
		{fprintf(logtext,"At Line no: %d parameter_list  : parameter_list COMMA type_specifier ID\n\n",line_no);
		  $$=new SymbolInfo($1->getName()+","+$3->getName()+" "+$4->getName(),"parameter_list");
		  fprintf(logtext,"%s,%s %s\n\n", $1->getName().c_str(),$3->getName().c_str(),$4->getName().c_str());
		  p_list.push_back($4->getName());
		   if($3->getName()=="int")
		  	{
							  i_dec.push_back("CONST_INT");

			}
			else if($3->getName()=="float")
		  	{
							  i_dec.push_back("CONST_FLOAT");

			}
			else if($3->getName()=="void")
		  	{
							  i_dec.push_back("VOID");

			}
		 }
		| parameter_list COMMA type_specifier
		{fprintf(logtext,"At Line no: %d parameter_list  : parameter_list COMMA type_specifier\n\n",line_no);
		  $$=new SymbolInfo($1->getName()+","+$3->getName(),"parameter_list");
		  fprintf(logtext,"%s,%s\n\n", $1->getName().c_str(),$3->getName().c_str());
		 }
		| type_specifier ID
		{fprintf(logtext,"At Line no: %d parameter_list  : type_specifier ID\n\n",line_no);
		  $$=new SymbolInfo($1->getName()+" "+$2->getName(),"parameter_list");
		  fprintf(logtext,"%s %s\n\n", $1->getName().c_str(),$2->getName().c_str());
		 p_list.push_back($2->getName());
		 
		  if($1->getName()=="int")
		  	{
							  i_dec.push_back("CONST_INT");

			}
			else if($1->getName()=="float")
		  	{
							  i_dec.push_back("CONST_FLOAT");

			}
			else if($1->getName()=="void")
		  	{
							  i_dec.push_back("VOID");

			}
		 }
		| type_specifier
		{fprintf(logtext,"At Line no: %d parameter_list  : type_specifier\n\n",line_no);
		  $$=new SymbolInfo($1->getName(),"parameter_list");
		  fprintf(logtext,"%s\n\n", $1->getName().c_str());
		 }
 		;

var_declaration : type_specifier declaration_list SEMICOLON
		{
		 fprintf(logtext,"At Line no: %d var_declaration : type_specifier declaration_list SEMICOLON\n\n",line_no);
		  $$=new SymbolInfo($1->getName()+" "+$2->getName()+";","var_declaration");
		  ////cout<<"id er vitore"<<endl;
		  fprintf(logtext,"%s %s;\n\n", $1->getName().c_str(),$2->getName().c_str());
		  ////cout<<$1->getName()<<endl;
			////cout<<"var\n";

			for(int i=0;i<id.size();i++)
			{
				if(table->cur_scope->Lookup(id[i])==NULL)
					{
					table->insert(id[i],"ID");
					SymbolInfo* ss= table->lookup(id[i]);
					if(ss!=NULL)
					if($1->getName()=="int")
		  	{
							  ss->tt="CONST_INT";
							  if(pointer[i])
							  {
							  		ss->tt="CONST_INT*";						  
							  }
							  else
							  {
								  var.push_back(id[i]+int_string(table->lookId()));
							  }
							  
			}
			else if($1->getName()=="float")
		  	{
							  ss->tt="CONST_FLOAT";
							  if(pointer[i])
							  {
							  		ss->tt="CONST_FLOAT*";						  
							  }
							   else
							  {
								  var.push_back(id[i]+int_string(table->lookId()));
							  }

			}
			else if($1->getName()=="void")
		  	{
					ss->tt="VOID";
				

			}
					}
				else
				{
                 fprintf(errortext,"Error at Line %d: Multiple Declaration of %s \n\n", line_no,id[i].c_str());
				 error++;
				}
			}
			 /*for(int i=0;i<id.size();i++)
			{
				var.push_back(id[i]+int_string(table->lookId(id[i])));
			}*/
			
			pointer.clear();
			id.clear();
		}
		;
	   
 		 

declaration_list : declaration_list COMMA ID
		 {
fprintf(logtext,"At Line no: %d declaration_list : declaration_list COMMA ID\n\n",line_no);
		  $$=new SymbolInfo($1->getName()+","+$3->getName(),"declaration_list");
		  fprintf(logtext,"%s,%s\n\n", $1->getName().c_str(),$3->getName().c_str());
		  id.push_back($3->getName());
		  list1.push_back(new SymbolInfo($3->getName(),"ID"));
		  pointer.push_back(false);
		  //i_dec.push_back($3->getName());
		 }
		 | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		 {
fprintf(logtext,"At Line no: %d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",line_no);
  $$=new SymbolInfo($1->getName()+","+$3->getName()+"["+$5->getName()+"]","declaration_list");
fprintf(logtext,"%s,%s[%s]\n\n", $1->getName().c_str(),$3->getName().c_str(),$5->getName().c_str());
id.push_back($3->getName());
list1.push_back(new SymbolInfo($3->getName(),"ID"+$5->getName()));
pointer.push_back(true);
$3->set_arr(1);
//i_dec.push_back($3->getName());
		 }
		 | ID
		 {fprintf(logtext,"At Line no: %d declaration_list : ID\n\n",line_no);
		  $$=new SymbolInfo($1->getName(),"declaration_list");
		  fprintf(logtext,"%s\n\n", $1->getName().c_str());
		  	list1.push_back(new SymbolInfo($1->getName(),"ID"));
			id.push_back($1->getName());
			pointer.push_back(false);
			
		 }
		 | ID LTHIRD CONST_INT RTHIRD
		 {
      fprintf(logtext,"At Line no: %d declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n",line_no);
		  $$=new SymbolInfo($1->getName()+"["+$3->getName()+"]","declaration_list");
		  fprintf(logtext,"%s[%s]\n\n", $1->getName().c_str(),$3->getName().c_str());
		  list1.push_back(new SymbolInfo($1->getName(),"ID"+$3->getName()));
		id.push_back($1->getName());
		pointer.push_back(true);
		$1->set_arr(1);
		//i_dec.push_back($1->getName());
		 }
 		 ;

type_specifier	: INT
		{fprintf(logtext,"At Line no: %d type_specifier : INT\n\n",line_no);
		$$=new SymbolInfo("int","INT");
		fprintf(logtext,"int\n\n");
		////cout<<$$->getName()<<endl;	
		//fprintf(logtext,"%s\n\n",$$->getName().c_str());
		}
 		| FLOAT
		{fprintf(logtext,"At Line no: %d type_specifier :FLOAT\n\n",line_no);
		$$=new SymbolInfo("float","FLOAT");	
		fprintf(logtext,"float\n\n");
		////cout<<$$->getName()<<endl;		
		}
 		| VOID
		{fprintf(logtext,"At Line no: %d type_specifier :VOID\n\n",line_no);	
		$$=new SymbolInfo("void","VOID");		
		fprintf(logtext,"void\n\n");
		////cout<<$$->getName()<<endl;
		}
 		;


 		
%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	
	yyin=fp;
	yyparse();
	
	fclose(fp);
	fclose(logtext);
	cout<<endl;
	return 0;
}

