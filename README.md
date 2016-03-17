# Remoting SDK CodeGen

This is the code generation logic for [RemObjects Remoting SDK](http://www.remotingsdk.com). It is based on our open source [CodeGen4](https://github.com/remobjects/CodeGen4) code generator.

## Platform support:

ROCodeGen can be used *on* (i.e. linked into tools written for) the following platforms:

* .NET, Cocoa and Java, via the [Elements](http://elementscompiler.com) compiler

ROCodeGen can be used to generate code *for* the following platforms:

* Cocoa (Objective-C, Apple Swift, Oxygene, Silver/Swift, RemObjects C#)
* Java (Java language, Oxygene, Silver/Swift, RemObjects C#)
* Delphi (Delphi Language, C++Builder)

It does not (yet) fully support:

* .NET (Server Access only; the rest of .NET codegen still uses CodeDom for now)
* JavaScript
* PHP
