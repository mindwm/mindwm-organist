let nonNegativeInteger = std.contract.from_predicate
  (
    fun value =>
      std.is_number value 
      && value >= 0
  ) in
let tmuxSessionName = std.contract.from_predicate
  # https://github.com/tmux/tmux/blob/3c3643f580ca718a5f6bbeea81abeb0a8bbdb131/session.c#L237
  (
    fun value =>
      std.string.is_match "^[^:.]*$" value
  ) in
let filePath = std.contract.from_predicate
  (
    fun value =>
      std.string.is_match "^\\/(?:[^\\/]+\\/)*[^\\/]+$" value
  ) in
{
  TmuxPane = {
    id 
     | nonNegativeInteger
     | doc "Tmux pane"
  },

  TmuxSession = 
  {
    name 
      |  tmuxSessionName
      | doc "A tmux session refers to a persistent set of windows and panes"
      | default 
      = "0",
    pane    
      | Array TmuxPane
  }, 

  TmuxServer =
  {
    socket   
      | filePath
      | doc "Tmux socket path",
    session 
      | Array TmuxSession
  }
} 

