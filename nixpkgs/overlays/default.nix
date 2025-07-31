self: super:

{
  kubectl-slice = super.callPackage ./kubectl-slice { };
  json-patch = super.callPackage ./json-patch { };
}
