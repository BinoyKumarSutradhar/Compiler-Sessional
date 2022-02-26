#include<bits/stdc++.h>
using namespace std;


class SymbolInfo
{
    string Name;
    string Type;
public:
    SymbolInfo * chain;

    SymbolInfo(string x, string y)
    {
        Name=x;
        Type=y;
        chain=NULL;
    }
    void setName(string x)
    {
        Name=x;
    }
    void setType(string x)
    {
        Type=x;
    }
    string getName()
    {
        return Name;
    }
    void setchain(SymbolInfo * element)
    {
        chain=element;
    }
    string getType()
    {
        return Type;
    }
    SymbolInfo * getchain()
    {
        return chain;
    }

};


class ScopeTable
{
    SymbolInfo **point;
    int serial;
    int h_size;
public:
    ScopeTable * parentScope;

    ScopeTable(int n, ScopeTable * parent, int no)
    {
        parentScope=parent;
        point=new SymbolInfo* [n];
        int i;
        for(i=0; i<n; i++)
        {
            point[i]=nullptr;
        }
        serial=no;
        h_size=n;
    }

    bool Insert(SymbolInfo ob);
    bool Delete(string x);
    void PrintTable();
    SymbolInfo* Lookup(string x);
    int Hashing(string x);
    int getserial()
    {
        return serial;
    }

    ~ScopeTable()
    {
        //delete(parentScope);
        int k;
        for(k=0;k<h_size;k++)
        {
            delete(point[k]);
        }
        delete[] point;
    }
};

int ScopeTable::Hashing(string x)
{
    int Sum = 0;
    int i;
    for (i = 0; i < x.length(); i++)
    {
        Sum=Sum + x[i];
    }

    return (Sum % h_size);
}

SymbolInfo* ScopeTable::Lookup(string x)
{
    int position = Hashing(x);
    int k=0;

    SymbolInfo* ptr = point[position];
    while(ptr)
    {
        if(ptr->getName() == x)
        {
            cout<<" Found in ScopeTable# "<<serial<<" at position "<<position<<", "<<k<<endl;
            return ptr;
        }
        k++;
        ptr = ptr->getchain();
    }

    cout<<x<<" not found"<<endl;
    return nullptr;
}

bool ScopeTable::Insert(SymbolInfo ob)
{
    string name = ob.getName();
    if(Lookup(name))
    {
       cout<<name<<" already exists in the current scope table "<<endl;
        return false;
    }

    int position = Hashing(name);
    SymbolInfo* ptr = point[position];
    if(!ptr)
    {
        point[position] = new SymbolInfo(ob.getName(), ob.getType());
        cout<<" Inserted in ScopeTable# "<<serial<<" at position "<<position<<", 0"<<endl;
    }
    else
    {
        int k=1;
        while(ptr->getchain())
        {
            k++;
            ptr = ptr->getchain();
        }
        SymbolInfo* current = new SymbolInfo(ob.getName(), ob.getType());
        ptr->setchain(current);
        cout<<" Inserted in ScopeTable# "<<serial<<" at position "<<position<<", "<<k<<endl;
    }

    return true;
}

bool ScopeTable::Delete(string x)
{
    int position = Hashing(x);

    SymbolInfo *ptr = point[position];
    SymbolInfo *prev = nullptr;

    int counter = 0;
    while(ptr)
    {
        if(ptr->getName() == x)
        {
            cout << "Found in ScopeTable #" << serial << " at position  " << position << " ," << counter << "\n";
            cout << "Deleted entry at " << position << " ," << counter <<"from current scopetable"<< "\n";
            if(!prev)
            {
                point[position] = ptr->getchain();
            }
            else
            {
                prev->setchain(ptr->getchain());
            }
            delete ptr;
            return true;
        }

        ++counter;
        prev = ptr;
        ptr = ptr->getchain();
    }
    cout<<x<<"  not found"<<endl;
    return false;
}

void ScopeTable::PrintTable()
{
    cout << "ScopeTable # " << serial << "\n";
    for(int i=0; i<h_size; i++)
    {
        cout << i << " --> ";
        SymbolInfo *ptr = point[i];
        while(ptr)
        {
            cout << "< " << ptr->getName() << " : " << ptr->getType() << " > ";
            ptr = ptr->getchain();
        }
        cout << "\n";
    }
}

class SymbolTable
{
    ScopeTable *cur_scope;
    int h_size;
    static int cnt;

public:

    SymbolTable(int h_size)
    {
        this->h_size = h_size;
        cur_scope = new ScopeTable(h_size, nullptr, ++cnt);
    }

    void enter_scope()
    {
        ScopeTable *new_scope = new ScopeTable(h_size, cur_scope, ++cnt);
        cur_scope = new_scope;
        cout<<" New ScopeTable with id "<<cur_scope->getserial()<<" created"<<endl;
    }

    void exit_scope()
    {
        if(cur_scope == nullptr)
        {
            cout<<"No scope table found"<<endl;
            return;
        }
        ScopeTable *temp_ptr = cur_scope;
        cur_scope = cur_scope->parentScope;
        cout<<"ScopeTable with id "<<temp_ptr->getserial()<<" removed"<<endl;
        delete temp_ptr ;
    }

    bool insert(SymbolInfo object)
    {
        return cur_scope->Insert(object);
    }

    bool remove(string x)
    {
        return cur_scope->Delete(x);
    }

    SymbolInfo* lookup(string x)
    {
        ScopeTable *ptr = cur_scope;
        while(ptr)
        {
            SymbolInfo *res = ptr->Lookup(x);
            if(res)
                return res;
            ptr = ptr->parentScope;
        }
        cout<<" not found "<<endl;
        return nullptr;
    }

    void printCurrentScope()
    {
        cur_scope->PrintTable();
    }

    void printAllScopes()
    {
        ScopeTable *ptr = cur_scope;
        while(ptr)
        {
            ptr->PrintTable();
            ptr = ptr->parentScope;
        }
    }
};

int SymbolTable::cnt = 0;

int main()
{
     freopen("input.txt", "r", stdin);
     freopen("output.txt", "w", stdout);

    int n;
    cin >> n;
    SymbolTable t(n);

    string operation;
    while(cin >> operation) {


        if(operation=="I")
        {
            string x;
            string y;
            cin>>x>>y;
            cout<<"I"<<" "<<x<<" "<<y<<endl;
            cout<<endl;
            t.insert(SymbolInfo(x, y));
            cout<<endl;
        }
        else if(operation=="L")
        {
            string x;
            cin>>x;
            cout<<"L"<<" "<<x<<endl;
            cout<<endl;
            t.lookup(x);
            cout<<endl;
        }
        else if(operation=="D")
        {
            string x;
            cin>>x;
            cout<<"D"<<" "<<x<<endl;
            cout<<endl;
            t.remove(x);
            cout<<endl;
        }
        else if(operation=="P")
        {
            string x;
            cin>>x;
            cout<<"P"<<" "<<x<<endl;
            cout<<endl;
            if(x=="A")
            {
                t.printAllScopes();
            }
            if(x=="C")
            {
                t.printCurrentScope();
            }
            cout<<endl;
        }
        else if(operation=="S")
        {

            cout<<"S"<<endl;
            cout<<endl;
            t.enter_scope();
            cout<<endl;
        }
        else if(operation=="E")
        {
            cout<<"E"<<endl;
            cout<<endl;
            t.exit_scope();
            cout<<endl;
        }


    }

    return 0;
}
