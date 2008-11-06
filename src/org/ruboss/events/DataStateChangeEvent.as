/*******************************************************************************
 * Copyright 2008, Ruboss Technology Corporation.
 *
 * This software is dual-licensed under both the terms of the Ruboss Commercial
 * License v1 (RCL v1) as published by Ruboss Technology Corporation and under
 * the terms of the GNU General Public License v3 (GPL v3) as published by the
 * Free Software Foundation.
 *
 * Both the RCL v1 (rcl-1.0.txt) and the GPL v3 (gpl-3.0.txt) are included in
 * the source code. If you have purchased a commercial license then only the
 * RCL v1 applies; otherwise, only the GPL v3 applies. To learn more or to buy a
 * commercial license, please go to http://ruboss.com.
 ******************************************************************************/
package org.ruboss.events {
  import flash.events.Event;

  /**
   * This event is dispatched Ruboss Models cache gets updated and can be
   * used to selectively refresh data providers, etc.
   */
  public class ModelStateChangeEvent extends Event {
    
    /** Event identifier */
    public static var ID:String = "dataStateChange";
    
    /** Fully qualified name of the model class that got updated */
    public var fqn:String;
    
    /** id of the item who's state has changed */
    public var itemID:int;
    public var prevState:int;
    public var newState:int;
    
    public function ModelStateChangeEvent(fqn:String) {
      super(ID, false, false);
      this.fqn = fqn;
    }
  }
}