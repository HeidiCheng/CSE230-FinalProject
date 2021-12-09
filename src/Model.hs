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
   b1 <- Ball.init P1;
  return PS
  { racket1     = Player.player1                  
  , racket2     = Player.player2                     
  , ball1       = b1 
  , ball2       = Ball.freeze       
  , result      = Nothing          
  , turn        = P1                    
  , score       = (0, 0)
  , secondBall  = False            
  }
}

initsc1 :: PlayState -> Turn -> Score -> IO PlayState
initsc1 s p sc@(sc1, sc2) = do
  b1 <- Ball.init p
  if ((sc1 == 3 && sc2 < 3) || (sc2 == 3 && sc1 < 3)) 
    then 
      do{ 
        b2 <- Ball.init p; 
        return s { ball1 = b1, ball2 = b2, score = sc, secondBall = True }
      }
    else return s { ball1 = b1, score = sc }


initsc2 :: PlayState -> Turn -> Score -> IO PlayState
initsc2 s p sc = do{
   b2 <- Ball.init p;
  return s { ball2 = b2, score   = sc }
}

next :: PlayState -> Ball.Result Ball.Ball -> Ball.Result Ball.Ball -> Either (Maybe Turn) (IO PlayState)
next s (Cont b1') (Cont b2') = Right (return (s { ball1 = b1', ball2 = b2'} ))
next s (Hit pl)   (Cont b2') = Right (return (s { ball1 = Ball.movement (Ball.reflect (ball1 s) pl), ball2 = b2' }))
next s (Cont b1') (Hit pl)   = Right (return (s { ball1 = b1', ball2 = Ball.movement (Ball.reflect (ball2 s) pl)}))
next s (Hit pl1)  (Hit pl2)  = Right (return (s { ball1 = Ball.movement (Ball.reflect (ball1 s) pl1), ball2 = Ball.movement (Ball.reflect (ball2 s) pl2)}))
next s (Score p)  _          = case (Score.addScore (score s) p) of
                                Left winner -> Left (Just winner)
                                Right sc -> Right (initsc1 s p sc)
next s  _         (Score p)  = case (Score.addScore (score s) p) of
                                Left winner -> Left (Just winner)
                                Right sc -> Right (initsc2 s p sc)
