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
        socket = "/tmp/tmux-1000/mindwm-ai-demo",
        session = [
          {
	    name = "teama",
	    pane = [     
	     {
	       id = 5
	     } 
	    ]
	  } 
        ]
      }      
    },
    {
      user =
      {
 	name = "user",
      },
      host = 
      [
        {
          name = "mindwm-dev1"
        }
      ],
      session_id = "efdc1f58-e5ef-11ee-91cf-83550cdc0865",
      tmux = {
        socket = "/tmp/tmux-1000/default",
        session = [
          {
	    name = "teama",
	    pane = [     
	     {
	       id = 0
	     } 
	    ]
	  } 
        ]
      }      
    },
    {
      user =
      {
 	name = "omg",
      },
      host = 
      [
        {
          name = "snpnd"
        }
      ],
      session_id = "f3a50b7a-ef42-11ee-926c-db9f7e4ee576",
      tmux = {
        socket = "/tmp/tmux-1000/mindwm-ai-demo",
        session = [
          {
	    name = "teama",
	    pane = [     
	     {
	       id = 0
	     } 
	    ]
	  } 
        ]
      }      
    }
  ]
#MINDWM_BACK_NATS_PORT=31137
#MINDWM_BACK_NATS_SUBJECT_PREFIX=mindwm.omg.snpnd.tmux.L3RtcC90bXV4LTEwMDAvbWluZHdtLWFpLWRlbW8=.f3a50b7a-ef42-11ee-926c-db9f7e4ee576.0.0
#MINDWM_BACK_NATS_HOST=127.0.0.1
#MINDWM_ASCIINEMA_REC_PIPE=/tmp/f3a50b7a-ef42-11ee-926c-db9f7e4ee576
}
