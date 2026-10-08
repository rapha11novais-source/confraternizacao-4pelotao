import { CalendarDays, MapPin, Users, LockKeyhole } from 'lucide-react';
export function EventSidebar({admin=false}:{admin?:boolean}) {
  return <aside className={'event-sidebar'+(admin?' compact':'')}>
    <a href="./" className="brand" aria-label="Formulário do 4º Pelotão"><span className="brand-mark">4<span>º</span></span><span>4º PELOTÃO<small>Confraternização 2026</small></span></a>
    <div className="sidebar-content">
    <div className="date-block"><strong>26</strong><div>OUTUBRO <span>2026</span></div></div>
    <div className="event-details"><p><CalendarDays size={19}/><span>Segunda-feira<small>26 de outubro de 2026</small></span></p><p><MapPin size={19}/><span>Clube LED<small>Cordeiros · Bahia</small></span></p><p><Users size={19}/><span>Policiais e convidados<small>Confraternização do 4º Pelotão</small></span></p></div>
    <div className="side-note">Sua confirmação ajuda a organização a planejar alimentação, bebidas e transporte.</div></div>
    <a className="admin-link" href={admin?'./':'#admin'}><LockKeyhole size={15}/>{admin?'Voltar ao formulário':'Área dos organizadores'}</a>
  </aside>;
}
export function Summary({entry}:{entry:{name:string;registration:string;municipality:string;attending:boolean;guests:string[]}}) {
  return <div className="summary"><dl><div><dt>Policial</dt><dd>{entry.name}</dd></div><div><dt>Matrícula</dt><dd>{entry.registration}</dd></div><div><dt>Município de lotação</dt><dd>{entry.municipality}</dd></div><div><dt>Presença</dt><dd><span className={'tag '+(entry.attending?'yes':'no')}>{entry.attending?'Presença confirmada':'Não comparecerá'}</span></dd></div><div><dt>Convidados</dt><dd>{entry.guests.length===0?'Nenhum convidado':`${entry.guests.length} ${entry.guests.length===1?'convidado':'convidados'}`}</dd></div></dl>{entry.guests.length>0&&<ol className="guest-list">{entry.guests.map((name,i)=><li key={i}><span>{String(i+1).padStart(2,'0')}</span>{name}</li>)}</ol>}</div>;
}

