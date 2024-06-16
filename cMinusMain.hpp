#ifndef _CMINUSMAIN_HPP_
#define _CMINUSMAIN_HPP_

// #define C_MINUS_DEBUG
// #define C_MINUS_FILE_IO

#include <string>
#include <vector>
using namespace std;

enum nodeType
{
    semantic,
    id,
    intType,
    floatType,
    intVal,
    floatVal,
    other,
};

union nodeVal
{
    string *id;
    int intVal;
    float floatVal;
};

struct node
{
    nodeType type;
    const char *word;
    int line;
    nodeVal val;
    vector<node *> sons;
    node() : sons{}, type(nodeType::other), val() {}
    node(nodeType type, int line, const char *word) : sons{}, line(line), type(type), word(word) {}
    node(nodeType type, int line, const char *word, int val) : sons{}, line(line), type(type), word(word)
    {
        this->val.intVal = val;
    }
    node(nodeType type, int line, const char *word, float val) : sons{}, line(line), type(type), word(word)
    {
        this->val.floatVal = val;
    }
    node(nodeType type, int line, const char *word, string *val) : sons{}, line(line), type(type), word(word)
    {
        this->val.id = val;
    }
};

void inline setNode(node *&theNode, const char *word, int line)
{
#ifdef C_MINUS_DEBUG
    printf("setNode: %s\n", word);
#endif // C_MINUS_DEBUG
    theNode = new node(nodeType::semantic, line, word);
    return;
}

void inline updateNodeLine(node *&theNode)
{
    int minn = theNode->line;
    for (auto &i : theNode->sons)
    {
        if (i == nullptr)
            continue;
        minn = min(minn, i->line);
    }
    theNode->line = minn;
}

template <typename T>
void inline setTNode(node *&theNode, int line, const char *word, T val, nodeType type)
{
#ifdef C_MINUS_DEBUG
    printf("setTNode: %s; val: %d, %f\n", word, val, val);
#endif // C_MINUS_DEBUG
    theNode = new node(type, line, word, val);
}

void inline setTNode(node *&theNode, int line, const char *word, nodeType type)
{
#ifdef C_MINUS_DEBUG
    printf("setTNode: %s\n", word);
#endif // C_MINUS_DEBUG
    theNode = new node(type, line, word);
}

#endif // _CMINUSMAIN_HPP_
