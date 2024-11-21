

#include "burner.h"
#include "splash.h"


extern BOOL IsCurrentlyInGame;
extern BOOL IsDATGenerationRequested;

HRESULT CSplashScene::OnInit( XUIMessageInit* pInitData, BOOL& bHandled )
{
 
	GetChildById( L"XuiButtonContinue", &m_Continue);
	GetChildById( L"XuiButtonDAT", &m_Dat);
 
	return S_OK;
}


HRESULT CSplashScene::OnNotifyPress( HXUIOBJ hObjPressed, BOOL& bHandled )
{
		if ( hObjPressed == m_Continue)
        {
			 
			IsCurrentlyInGame = true;
			bHandled = TRUE;
			return S_OK;
			
        }

		if ( hObjPressed == m_Dat)
        {
			IsDATGenerationRequested = true;
			bHandled = TRUE;
			return S_OK;

        }

}

HRESULT CSplashScene::OnTimer(XUIMessageTimer *pXUIMessageTimer, BOOL& bHandled)
{
		if ( pXUIMessageTimer->nId == 1)
        {

			IsCurrentlyInGame = true;
			bHandled = TRUE;
			return S_OK;
        }
 
}