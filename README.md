# SwiftHDL

A Hardware Description Language (HDL) embedded in Swift, inspired by Chisel

## Some Commands

```bash
swift build
swift run SwiftHDLExamples
```

or alternatively

```bash
just run
```

## Roadmap

- [ ] Bundles
    - Handle?
- [ ] Module/Component system


## Notes

- Should we try emitting a graph form of the frontend or just a statement form like chisel?

Think it is better to emit a stmt based output that can be parsed using existing parsing frameworks.
Especially if we want to have a polyglot approach and have an interop interface between the IR & frontend infra
