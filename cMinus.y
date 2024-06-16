%union {
    struct node* node;
}

%{
    #include<cMinusMain.hpp>
    extern struct node* root;
    extern int codeLine;
    extern int yylex (void);
    extern bool isSuccess;
    void yyerror (char const *s);
%}

%token <node> INT
%token <node> FLOAT
%token <node> ID

%right <node> ASSIGNOP
%left <node> OR
%left <node> AND
%left <node> RELOP
%left <node> PLUS MINUS
%left <node> STAR DIV
%right <node> NOT
%left <node> LP RP LB RB DOT

%precedence <node> ELSE
%token <node> STRUCT RETURN IF WHILE SEMI COMMA TYPE LC RC

%type <node> Program ExtDefList ExtDef ExtDecList Specifier
    StructSpecifier OptTag Tag VarDec FunDec VarList ParamDec
    CompSt StmtList Stmt DefList Def DecList Dec Exp Args
    ErrorSemi ErrorRp ErrorRb ErrorRc

%start Program

%%

ErrorSemi
    : error SEMI { $$ = $2; }
    | SEMI { $$ = $1; }
    ;

ErrorRp
    : error RP { $$ = $2; }
    | RP { $$ = $1; }
    ;

ErrorRb
    : error RB { $$ = $2; }
    | RB { $$ = $1; }
    ;

ErrorRc
    : error RC { $$ = $2; }
    | RC { $$ = $1; }
    ;

Program
    : ExtDefList {
        setNode($$, "Program", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
        root = $$;
    }
    ;
ExtDefList
    : ExtDef ExtDefList {
        setNode($$, "ExtDefList", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        updateNodeLine($$);
    }
    | %empty { $$ = nullptr; }
    ;
ExtDef
    : Specifier ExtDecList ErrorSemi {
        setNode($$, "ExtDef", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | Specifier ErrorSemi {
        setNode($$, "ExtDef", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        updateNodeLine($$);
    }
    | Specifier FunDec CompSt {
        setNode($$, "ExtDef", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    ;
ExtDecList
    : VarDec {
        setNode($$, "ExtDecList", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    | VarDec COMMA ExtDecList {
        setNode($$, "ExtDecList", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    ;

Specifier
    : TYPE {
        setNode($$, "Specifier", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    | StructSpecifier {
        setNode($$, "Specifier", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    ;
StructSpecifier
    : STRUCT OptTag LC DefList ErrorRc {
        setNode($$, "StructSpecifier", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        $$->sons.emplace_back($5);
        updateNodeLine($$);
    }
    | STRUCT Tag {
        setNode($$, "StructSpecifier", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        updateNodeLine($$);
    }
    ;
OptTag
    : ID {
        setNode($$, "OptTag", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    | %empty { $$ = nullptr; }
    ;
Tag
    : ID {
        setNode($$, "Tag", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    ;

VarDec
    : ID {
        setNode($$, "VarDec", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    | VarDec LB INT ErrorRb {
        setNode($$, "VarDec", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        updateNodeLine($$);
    }
    ;
FunDec
    : ID LP VarList ErrorRp {
        setNode($$, "FunDec", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        updateNodeLine($$);
    }
    | ID LP ErrorRp {
        setNode($$, "FunDec", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    ;
VarList
    : ParamDec COMMA VarList {
        setNode($$, "VarList", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | ParamDec {
        setNode($$, "VarList", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    ;
ParamDec
    : Specifier VarDec {
        setNode($$, "ParamDec", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        updateNodeLine($$);
    }
    ;

CompSt
    : LC DefList StmtList ErrorRc {
        setNode($$, "CompSt", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        updateNodeLine($$);
    }
    ;
StmtList
    : Stmt StmtList {
        setNode($$, "StmtList", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        updateNodeLine($$);
    }
    | %empty { $$ = nullptr; }
    ;
Stmt
    : Exp ErrorSemi {
        setNode($$, "Stmt", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        updateNodeLine($$);
    }
    | CompSt {
        setNode($$, "Stmt", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    | RETURN Exp ErrorSemi {
        setNode($$, "Stmt", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | IF LP Exp ErrorRp Stmt {
        setNode($$, "Stmt", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        $$->sons.emplace_back($5);
        updateNodeLine($$);
    }
    | IF LP Exp ErrorRp Stmt ELSE Stmt {
        setNode($$, "Stmt", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        $$->sons.emplace_back($5);
        $$->sons.emplace_back($6);
        $$->sons.emplace_back($7);
        updateNodeLine($$);
    }
    | WHILE LP Exp ErrorRp Stmt {
        setNode($$, "Stmt", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        $$->sons.emplace_back($5);
        updateNodeLine($$);
    }
    ;

DefList
    : Def DefList {
        setNode($$, "DefList", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        updateNodeLine($$);
    }
    | %empty { $$ = nullptr; }
    ;
Def
    : Specifier DecList ErrorSemi {
        setNode($$, "Def", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    ;
DecList
    : Dec {
        setNode($$, "DecList", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    | Dec COMMA DecList {
        setNode($$, "DecList", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    ;
Dec
    : VarDec {
        setNode($$, "Dec", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    | VarDec ASSIGNOP Exp {
        setNode($$, "Dec", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    ;

Exp
    :Exp ASSIGNOP Exp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | Exp AND Exp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | Exp OR Exp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | Exp RELOP Exp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | Exp PLUS Exp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | Exp MINUS Exp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | Exp STAR Exp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | Exp DIV Exp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | LP Exp ErrorRp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | MINUS Exp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        updateNodeLine($$);
    }
    | NOT Exp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        updateNodeLine($$);
    }
    | ID LP Args ErrorRp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        updateNodeLine($$);
    }
    | ID LP ErrorRp {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | Exp LB Exp ErrorRb {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        updateNodeLine($$);
    }
    | Exp DOT ID {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | ID {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    | INT {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    | FLOAT {
        setNode($$, "Exp", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    ;
Args
    : Exp COMMA Args {
        setNode($$, "Args", codeLine);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        updateNodeLine($$);
    }
    | Exp {
        setNode($$, "Args", codeLine);
        $$->sons.emplace_back($1);
        updateNodeLine($$);
    }
    ;

%%

void yyerror (char const *s)
{
    isSuccess = false;
    printf("Error type B at Line %d: %s\n", codeLine, s);
}
