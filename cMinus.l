%option noyywrap yylineno

%{
    #include<string>
    #include "cMinusMain.hpp"
    #include "cMinus.tab.h"
    using namespace std;
    
    extern bool isSuccess;
%}

INT 0|[1-9]\d*
INT_OCT 0[0-7]+
INT_HEX 0x[0-9a-fA-F]+
FLOAT {INT}\.{INT}
SIMPLE_FLOAT {INT}\.|\.{INT}
FLOAT_E {SIMPLE_FLOAT}[Ee][+-]?{INT}

SEMI ;
COMMA ,
ASSIGNOP =
RELOP >|<|>=|<=|==|!=
PLUS \+
MINUS \-
STAR \*
DIV \/
AND &&
OR \|\|
DOT \.
NOT \!
TYPE int|float
LP \(
RP \)
LB \[
RB \]
LC \{
RC \}
STRUCT struct
RETURN return
IF if
ELSE else
WHILE while

ID [_a-zA-Z][_a-zA-Z0-9]*

%x COMMENTS
%%

"//".* { }
"/*" { BEGIN(COMMENTS); }
<COMMENTS>"*/" { BEGIN(INITIAL); }
<COMMENTS>\n { }
<COMMENTS>. { }

{INT} { setTNode(yylval.node, "INT", stoi(yytext, nullptr), nodeType::intVal); return INT; }
{INT_OCT} { setTNode(yylval.node, "INT", stoi(yytext, nullptr, 8), nodeType::intVal); return INT; }
{INT_HEX} { setTNode(yylval.node, "INT", stoi(yytext, nullptr, 16), nodeType::intVal); return INT; }
{SIMPLE_FLOAT} { setTNode(yylval.node, "FLOAT", stof(yytext, nullptr), nodeType::floatVal); return FLOAT; }
{FLOAT_E} { setTNode(yylval.node, "FLOAT", stof(yytext, nullptr), nodeType::floatVal); return FLOAT; }

{TYPE} { setTNode(yylval.node, "TYPE", yytext[0]=='i'? nodeType::intType :nodeType::floatType); return TYPE; }

{SEMI} { setTNode(yylval.node, "SEMI", nodeType::other); return SEMI; }
{COMMA} { setTNode(yylval.node, "COMMA", nodeType::other); return COMMA; }
{ASSIGNOP} { setTNode(yylval.node, "ASSIGNOP", nodeType::other); return ASSIGNOP; }
{RELOP} { setTNode(yylval.node, "RELOP", nodeType::other); return RELOP; }
{PLUS} { setTNode(yylval.node, "PLUS", nodeType::other); return PLUS; }
{MINUS} { setTNode(yylval.node, "MINUS", nodeType::other); return MINUS; }
{STAR} { setTNode(yylval.node, "STAR", nodeType::other); return STAR; }
{DIV} { setTNode(yylval.node, "DIV", nodeType::other); return DIV; }
{AND} { setTNode(yylval.node, "AND", nodeType::other); return AND; }
{OR} { setTNode(yylval.node, "OR", nodeType::other); return OR; }
{DOT} { setTNode(yylval.node, "DOT", nodeType::other); return DOT; }
{NOT} { setTNode(yylval.node, "NOT", nodeType::other); return NOT; }
{LP} { setTNode(yylval.node, "LP", nodeType::other); return LP; }
{RP} { setTNode(yylval.node, "RP", nodeType::other); return RP; }
{LB} { setTNode(yylval.node, "LB", nodeType::other); return LB; }
{RB} { setTNode(yylval.node, "RB", nodeType::other); return RB; }
{LC} { setTNode(yylval.node, "LC", nodeType::other); return LC; }
{RC} { setTNode(yylval.node, "RC", nodeType::other); return RC; }
{STRUCT} { setTNode(yylval.node, "STRUCT", nodeType::other); return STRUCT; }
{RETURN} { setTNode(yylval.node, "RETURN", nodeType::other); return RETURN; }
{IF} { setTNode(yylval.node, "IF", nodeType::other); return IF; }
{ELSE} { setTNode(yylval.node, "ELSE", nodeType::other); return ELSE; }
{WHILE} { setTNode(yylval.node, "WHILE", nodeType::other); return WHILE; }

{ID} { string* idName = new string(yytext); setTNode(yylval.node, "ID", idName, nodeType::id); return WHILE; }

[ \t\n] { }
. { isSuccess = false; printf("Error type A at Line %d: %s\n", yylineno, yytext); }

%%
