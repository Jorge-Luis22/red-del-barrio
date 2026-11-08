import { AppProvider, useApp } from './state/app';
import TabBar from './components/TabBar';
import Onboarding from './components/Onboarding';
import Tutorial from './components/Tutorial';
import Inicio from './pages/Inicio';
import Vecinos from './pages/Vecinos';
import Mensajes from './pages/Mensajes';
import Emergencia from './pages/Emergencia';
import Perfil from './pages/Perfil';
import NeedView from './pages/NeedView';
import ChatView from './pages/ChatView';

function Shell() {
  const { ready, me, tab, screen, needsOnboarding, notice, completeOnboarding } = useApp();

  if (!ready) return <div className="boot">Abriendo la base local…</div>;
  if (needsOnboarding) return <Onboarding notice={notice} onDone={completeOnboarding} />;
  if (!me) return <div className="boot">No se pudo cargar ningún vecino.</div>;

  return (
    <div className="shell">
      <main className="content">
        {screen.name === 'need' && <NeedView needId={screen.id} />}
        {screen.name === 'chat' && <ChatView conversationId={screen.id} />}
        {screen.name === 'none' && (
          <>
            {tab === 'inicio' && <Inicio />}
            {tab === 'vecinos' && <Vecinos />}
            {tab === 'mensajes' && <Mensajes />}
            {tab === 'emergencia' && <Emergencia />}
            {tab === 'perfil' && <Perfil />}
          </>
        )}
      </main>
      {screen.name === 'none' && <TabBar />}
      <Tutorial />
    </div>
  );
}

export default function App() {
  return (
    <AppProvider>
      <Shell />
    </AppProvider>
  );
}
