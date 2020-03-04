#!/usr/local/bin/thrift --gen py --gen cpp -r -o .

namespace cpp thrift
namespace py thrift

struct Demo {
    1: string name;
    2: i32 id;
}

service Server {   
    i32 id(1:string name),
    string id(1:i32 id)
}
