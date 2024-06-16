%option noyywrap

%{
    #include<string>
    #include "cMinusMain.hpp"
    #include "cMinus.tab.h"
    using namespace std;

    extern bool isSuccess;
    int codeLine = 1;

    int stoiCatch(const char* str, int base = 10);
    float stofCatch(const char* str);
%}

WORD [a-zA-Z0-9_]

INT 0|[1-9][0-9]*{WORD}*
INT_OCT 0[0-7]+{WORD}*
INT_HEX 0x[0-9a-fA-F]+{WORD}*
FLOAT {INT}\.{INT}
SIMPLE_FLOAT ({INT}\.|\.{INT}|{FLOAT}){WORD}*
FLOAT_E ({SIMPLE_FLOAT}|{INT})[Ee][+-]?{INT}

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

ID [_a-zA-Z]{WORD}*

%x COMMENTS
%%

"//".* { }
"/*" { BEGIN(COMMENTS); }
<COMMENTS>"*/" { BEGIN(INITIAL); }
<COMMENTS>\n { codeLine++; }
<COMMENTS>. { }

{INT} { setTNode(yylval.node, codeLine, "INT", stoiCatch(yytext), nodeType::intVal); return INT; }
{INT_OCT} { setTNode(yylval.node, codeLine, "INT", stoiCatch(yytext, 8), nodeType::intVal); return INT; }
{INT_HEX} { setTNode(yylval.node, codeLine, "INT", stoiCatch(yytext, 16), nodeType::intVal); return INT; }
{SIMPLE_FLOAT} { setTNode(yylval.node, codeLine, "FLOAT", stofCatch(yytext), nodeType::floatVal); return FLOAT; }
{FLOAT_E} { setTNode(yylval.node, codeLine, "FLOAT", stofCatch(yytext), nodeType::floatVal); return FLOAT; }

{TYPE} { setTNode(yylval.node, codeLine, "TYPE", yytext[0]=='i'? nodeType::intType :nodeType::floatType); return TYPE; }

{SEMI} { setTNode(yylval.node, codeLine, "SEMI", nodeType::other); return SEMI; }
{COMMA} { setTNode(yylval.node, codeLine, "COMMA", nodeType::other); return COMMA; }
{ASSIGNOP} { setTNode(yylval.node, codeLine, "ASSIGNOP", nodeType::other); return ASSIGNOP; }
{RELOP} { setTNode(yylval.node, codeLine, "RELOP", nodeType::other); return RELOP; }
{PLUS} { setTNode(yylval.node, codeLine, "PLUS", nodeType::other); return PLUS; }
{MINUS} { setTNode(yylval.node, codeLine, "MINUS", nodeType::other); return MINUS; }
{STAR} { setTNode(yylval.node, codeLine, "STAR", nodeType::other); return STAR; }
{DIV} { setTNode(yylval.node, codeLine, "DIV", nodeType::other); return DIV; }
{AND} { setTNode(yylval.node, codeLine, "AND", nodeType::other); return AND; }
{OR} { setTNode(yylval.node, codeLine, "OR", nodeType::other); return OR; }
{DOT} { setTNode(yylval.node, codeLine, "DOT", nodeType::other); return DOT; }
{NOT} { setTNode(yylval.node, codeLine, "NOT", nodeType::other); return NOT; }
{LP} { setTNode(yylval.node, codeLine, "LP", nodeType::other); return LP; }
{RP} { setTNode(yylval.node, codeLine, "RP", nodeType::other); return RP; }
{LB} { setTNode(yylval.node, codeLine, "LB", nodeType::other); return LB; }
{RB} { setTNode(yylval.node, codeLine, "RB", nodeType::other); return RB; }
{LC} { setTNode(yylval.node, codeLine, "LC", nodeType::other); return LC; }
{RC} { setTNode(yylval.node, codeLine, "RC", nodeType::other); return RC; }
{STRUCT} { setTNode(yylval.node, codeLine, "STRUCT", nodeType::other); return STRUCT; }
{RETURN} { setTNode(yylval.node, codeLine, "RETURN", nodeType::other); return RETURN; }
{IF} { setTNode(yylval.node, codeLine, "IF", nodeType::other); return IF; }
{ELSE} { setTNode(yylval.node, codeLine, "ELSE", nodeType::other); return ELSE; }
{WHILE} { setTNode(yylval.node, codeLine, "WHILE", nodeType::other); return WHILE; }

{ID} { string* idName = new string(yytext); setTNode(yylval.node, codeLine, "ID", idName, nodeType::id); return ID; }

[ \f\v\s\t\r] { }
[\n] { codeLine++; }
. { isSuccess = false; printf("Error type A at Line %d: Mysterious character \"%s\"\n", codeLine, yytext); }

%%

int stoiCatch(const char* str, int base) {
    bool localSuccess = true;
    size_t slen = 0;
    int res = 0;
    try {
        res = stoi(str, &slen, base);
        if(slen != strlen(str)) {
            localSuccess = false;
        }
    } catch (...) {
        localSuccess = false;
    }
    if(!localSuccess) {
        isSuccess = false;
        printf("Error type A at Line %d: \"%s\" is not a valid %s int integer\n", codeLine, str, base == 10 ? "decimal" : base == 8 ? "octal" : "hexadecimal");
    }
    return res;
}

float stofCatch(const char* str) {
    bool localSuccess = true;
    size_t slen = 0;
    float res = 0;
    try {
        res = stof(str, &slen);
        if(slen != strlen(str)) {
            localSuccess = false;
        }
    } catch (...) {
        localSuccess = false;
    }
    if(!localSuccess) {
        isSuccess = false;
        printf("Error type A at Line %d: \"%s\" is not a valid float\n", codeLine, str);
    }
    return res;
}
