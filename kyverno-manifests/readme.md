## Kyverno cluster Wide Policy Explanation -->

###  This works at validation Webhook Admission Controller 

Under the spec section of the Policy, there is a an attribute validationFailureAction it tells Kyverno if the resource being validated should be allowed but reported Audit or blocked Enforce.

Defaults to Audit, the example is set to Enforce.

The rules is one or more rules to be validated.

The match statement sets the scope of what will be checked. In this case, it is any Pod resource.

The validate statement tries to positively check what is defined. If the statement, when compared with the requested resource, is true, it is allowed. If false, it is blocked.

The message is what gets displayed to a user if this rule fails validation.

The pattern object defines what pattern will be checked in the resource. In this case, it is looking for metadata.labels with CostCenter.

The Above Example Policy, will block any Pod Creation which doesn't have the label CostCenter.


kubectl get policyreports -A