#include <cMinusMain.hpp>
#include <cMinus.tab.h>
#include <stdio.h>

node *root = nullptr;
extern FILE *yyin;
bool isSuccess;

void printNode(node *x, int level = 0)
{
    if (x == nullptr)
        return;

    for (int i = 0; i < level; i++)
        printf("  ");
    printf("%s", x->word);

    switch (x->type)
    {
    case nodeType::semantic:
        printf(" (%d)\n", x->val.intVal);
        break;
    case nodeType::id:
        printf("ID: %s\n", x->val.id->c_str());
        break;
    case nodeType::intType:
        printf("TYPE: int\n");
        break;
    case nodeType::floatType:
        printf("TYPE: float\n");
        break;
    case nodeType::intVal:
        printf("INT: %d\n", x->val.intVal);
        break;
    case nodeType::floatVal:
        printf("FLOAT: %f\n", x->val.floatVal);
        break;
    case nodeType::other:
        printf("What is this? %s\n", x->word);
        break;
    default:
        break;
    }
    for (auto i : x->sons)
    {
        printNode(i, level + 1);
    }
}

int main(int argc, char **argv)
{
    const char *fileName;
    isSuccess = true;
    if (argc < 2)
    {
        fileName = "/home/aldlss/code/homework/cMinus/text1.in";
        puts("0");
        // return 0;
    }
    else
        fileName = argv[1];
    yyin = fopen(fileName, "r");
    if (!yyin)
        return 0;
    // yyin = nullptr;
    puts("start parse");
    yyparse();
    fclose(yyin);
    puts("parse success");

    if (isSuccess)
        printNode(root);
    puts("end");

    return 0;
}
