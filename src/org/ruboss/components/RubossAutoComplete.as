package org.ruboss.components {
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.TimerEvent;
  import flash.ui.Keyboard;
  import flash.utils.Timer;
  
  import mx.controls.ComboBox;
  import mx.core.UIComponent;
  
  import org.ruboss.Ruboss;
  import org.ruboss.collections.RubossCollection;
  import org.ruboss.models.RubossModel;
  import org.ruboss.utils.RubossUtils;
  
  [Exclude(name="editable", kind="property")]
  [Event(name="typedTextChange", type="flash.events.Event")]
  [Event(name="selectedItemShown", type="flash.events.Event")]
  
  [Bindable]
  public class RubossAutoComplete extends ComboBox {
    
    public var resource:Class;
    
    public var filterFunction:Function;
    
    public var lookupDelay:int = 500;
    
    public var lookupMinChars:int = 1;
  
    private var resourceSearched:Boolean;
    
    private var currentSearch:String;
    
    private var searchInProgress:Boolean;

    private var _typedText:String = "";

    private var typedTextChanged:Boolean;
  
    private var cursorPosition:Number = 0;

    private var prevIndex:Number = -1;

    private var showDropdown:Boolean=false;

    private var showingDropdown:Boolean=false;

    private var dropdownClosed:Boolean=true;

    private var delayTimer:Timer;

    private var searchResults:RubossCollection;
  
    public function RubossAutoComplete() {
      super();
      searchResults = new RubossCollection;
      editable = true;
      setStyle("arrowButtonWidth",0);
      setStyle("fontWeight","normal");
      setStyle("cornerRadius",0);
      setStyle("paddingLeft",0);
      setStyle("paddingRight",0);
      rowCount = 7;
      
      addEventListener("typedTextChange",onTextChange);
    }
  
    private function onTextChange(event:Event):void {
      searchResults.refresh();
      if (RubossUtils.isEmpty(typedText)) {
        if (!searchResults.length) resourceSearched = false;
        return;
      }
      
      if (typedText != currentSearch) {
        if (!searchResults.length) resourceSearched = false;
      }
      
      if (!resourceSearched && !searchInProgress) {
        searchInProgress = true;
        if (delayTimer != null && delayTimer.running) {
          delayTimer.stop();
        }
        
        delayTimer = new Timer(lookupDelay, 1);
        delayTimer.addEventListener(TimerEvent.TIMER, invokeSearch);
        delayTimer.start();
      }
    }
    
    private function invokeSearch(event:TimerEvent):void {
      if (RubossUtils.isEmpty(typedText)) return;
      Ruboss.http(onResourceSearch).invoke({URL:
        RubossUtils.nestResource(resource), data: {search: typedText}, cacheBy: "page"});
    }
        
    private function onResourceSearch(results:Object):void {
      searchResults = Ruboss.filter(Ruboss.models.cached(resource), filterFunction);
      searchResults.refresh();
      resourceSearched = true;
      searchInProgress = false;
      dataProvider = searchResults;
    }
  
    private function onSearchFault(info:Object, token:Object = null):void {
      trace("Not Happy: ",info);  
    }
  
    [Bindable("typedTextChange")]
    [Inspectable(category="Data")]
    public function get typedText():String {
        return _typedText;
    }
    
    public function set typedText(input:String):void {
      _typedText = input;
      typedTextChanged = true;
        
      invalidateProperties();
      invalidateDisplayList();
      dispatchEvent(new Event("typedTextChange"));
    }
  
    override protected function commitProperties():void {
      super.commitProperties();
    
      if(!dropdown) selectedIndex = -1;
      if(dropdown) {
        if(typedTextChanged) {
          cursorPosition = textInput.selectionBeginIndex;
    
          //In case there are no suggestions there is no need to show the dropdown
          if(searchResults.length == 0) {
            dropdownClosed = true;
            showDropdown = false;
          } else {
            showDropdown = true;
            selectedIndex = 0;
          }
        }
      }
    }
      
    override public function getStyle(styleProp:String):* {
      if (styleProp != "openDuration") {
        return super.getStyle(styleProp);
      } else {
        if (dropdownClosed) {
          return super.getStyle(styleProp);
        } else {
          return 0;
        }
      }
    }
  
    override protected function keyDownHandler(event:KeyboardEvent):void {
      super.keyDownHandler(event);
    
      if(!event.ctrlKey) {
        //An UP "keydown" event on the top-most item in the drop-down
        //or an ESCAPE "keydown" event should change the text in text
        // field to original text
        if(event.keyCode == Keyboard.UP && prevIndex == 0) {
          textInput.text = _typedText;
          textInput.setSelection(textInput.text.length, textInput.text.length);
          selectedIndex = -1; 
        } else if(event.keyCode == Keyboard.ESCAPE && showingDropdown) {
          textInput.text = _typedText;
          textInput.setSelection(textInput.text.length, textInput.text.length);
          showingDropdown = false;
          dropdownClosed = true;
        } else if (event.keyCode == Keyboard.ENTER) {
          if (selectedItem != null) {
            if (RubossModel(selectedItem).show({afterCallback: onResourceShow, useLazyMode: true})) {
              onResourceShow(selectedItem);
            }           
          }
        }
      } else if (event.ctrlKey && event.keyCode == Keyboard.UP) {
        dropdownClosed = true;
      }
    
      prevIndex = selectedIndex;
    }
    
    private function onResourceShow(result:Object):void {
      selectedItem = result;
      dispatchEvent(new Event("selectedItemShown"));
    }
    
    override protected function measure():void {
      super.measure();
      measuredWidth = mx.core.UIComponent.DEFAULT_MEASURED_WIDTH;
    }
  
    override protected function updateDisplayList(unscaledWidth:Number, 
      unscaledHeight:Number):void {
      
      super.updateDisplayList(unscaledWidth, unscaledHeight);
      if (selectedIndex == -1) textInput.text = typedText;
  
      if (dropdown) {
        if (typedTextChanged) {
          //This is needed because a call to super.updateDisplayList() set the text
          // in the textInput to "" and thus the value 
          //typed by the user losts
          textInput.text = _typedText;
          textInput.setSelection(cursorPosition, cursorPosition);
          typedTextChanged = false;
        } else if (typedText) {
          //Sets the selection when user navigates the suggestion list through
          //arrows keys.
          textInput.setSelection(_typedText.length,textInput.text.length);
        }
        
        if (showDropdown && !dropdown.visible) {
          //This is needed to control the open duration of the dropdown
          super.open();
          showDropdown = false;
          showingDropdown = true;
  
          if (dropdownClosed) dropdownClosed=false;
        }
      }
    }
    
    override protected function textInput_changeHandler(event:Event):void {
      super.textInput_changeHandler(event);
      typedText = text;
    }
    
    override public function close(event:Event = null):void {
      super.close(event);
        
      if (selectedIndex == 0) {
        textInput.text = selectedLabel;
        textInput.setSelection(cursorPosition, textInput.text.length);      
      }      
    } 
  }
}
