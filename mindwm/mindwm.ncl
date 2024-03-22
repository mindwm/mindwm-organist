let { MindwmTmuxPaneSession, .. } = import "./mindwm-schema.ncl" in
{
  MindwmSessions | Array MindwmTmuxPaneSession = [
    {
      user =
      {
 	name = "bebebeko",
      },
      host = 
      [
        {
          name = "amanda"
        }
      ],
      session_id = "982bd7be-e831-11ee-9f2f-a732b78f201b",
      tmux = {
        socket = "/tmp/tmux-1000/default",
        session = [
          {
	    name = "abc",
	    pane = [     
	     {
	       id = 5
	     } 
	    ]
	  } 
        ]
      }      
    }
  ]
}
