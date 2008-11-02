package org.ruboss.validators {
  import mx.validators.ValidationResult;
  import mx.validators.Validator;

  public class StringEqualityValidator extends Validator {
    /**
     * The password being compared to the confirmation.
     */
    public var stringToCompare:String;

    public var mismatchError:String = "The password does not match the confirmation.";

    public function StringEqualityValidator() {
      super();
    }
        
    override protected function doValidation(stringConfirmation:Object):Array {
      //We call base class doValidation() to get the required logic.
      var results:Array =
          super.doValidation(stringConfirmation);

      // Compare stringToCompare and stringConfirmation fields.
      if (stringToCompare != stringConfirmation) {
          results.push(
              new ValidationResult(
                  true,
                  "string_confirmation",
                  "stringDoesNotMatchConfirmation",
              mismatchError));
      }            
      return results;
    }
  }
}