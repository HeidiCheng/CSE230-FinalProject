{-# LANGUAGE RecordWildCards #-}

module Model where 

import Prelude hiding ((!!))
import Types
import qualified Model.Ball   as Ball
import qualified Model.Score  as Score
import qualified Model.Player as Player

-------------------------------------------------------------------------------
-- | Top-level App State ------------------------------------------------------
-------------------------------------------------------------------------------

init :: IO PlayState
init = do{
   b <- Ball.init;
  return PS
  { racket1 = Player.player1                  
  , racket2 = Player.player2                     
  , ball    = b       
  , result  = Nothing          
  , turn    = P1                    
  , score   = (0, 0)                
  }
}

next :: PlayState -> Ball.Result Ball.Ball -> Either (Maybe Turn) PlayState
next s (Cont b') = Right (s { ball = b' } )
next s (Hit pl) = Right (s { ball = Ball.movement (Ball.reflect (ball s) pl) })
next s (Score p) = case (Score.addScore (score s) p) of
                         Left winner -> Left (Just winner)
                         Right sc -> Right (s { ball = Ball.serveBall p, score = sc })
