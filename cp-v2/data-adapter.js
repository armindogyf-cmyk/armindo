(function(){
const core=window.CP_CORE||{};
const mapRows=(rows,fields)=>(rows||[]).map(r=>Object.fromEntries((fields||[]).map((f,i)=>[f,r[i]])));
const sysCode={
'Motor — estrutura':'ENG','Distribuição':'TIM','Lubrificação':'LUB','Arrefecimento':'CLG','Combustível e admissão':'FUE','Ignição e gestão do motor':'IGN','Escape e emissões':'EXH','Transmissão e embraiagem':'TRN','Transmissão às rodas':'DRV','Suspensão':'SUS','Direção':'STR','Travagem':'BRK','Elétrica, carga e arranque':'ELC','Iluminação e sinalização':'LGT','Climatização e ventilação':'HVA','Carroçaria e exterior':'BDY','Vidros, limpeza e vedação':'GLS','Interior e comandos':'INT','Retenção e segurança passiva':'SRS','Manutenção, consumíveis e fixação':'SRV'};
const parts=mapRows(window.CP_PARTS,window.CP_PARTS_FIELDS).map(p=>({...p,
  'Cód. sistema':sysCode[p.Sistema]||'', 'Posição':'—','Segurança':'—','PN OEM':null,'Marca IAM':null,'PN IAM':null,'Confiança %':null,'Fonte':'Inventário CP V1'}));
const faults=mapRows(window.CP_FAULTS,window.CP_FAULTS_FIELDS).map(f=>({...f,'Regra de decisão':f['Regra de decisão']||'Registar observação e validar segundo a fonte técnica aplicável antes da intervenção.'}));
const tasks=mapRows(window.CP_TASKS,window.CP_TASKS_FIELDS).map(t=>({...t,Justificação:t.Justificação||t['Evidência exigida']||''}));
const sources=mapRows(window.CP_SOURCES,window.CP_SOURCES_FIELDS);
const rules=mapRows(window.CP_RULES,window.CP_RULES_FIELDS);
const vehicle=(core.vehicle||[]).map(v=>v.Campo==='Matrícula'?{...v,Valor:'80-**-PJ','Evidência / nota':'Matrícula mascarada na versão pública; valor integral preservado no dossier controlado.'}:v);
window.CP_DATA={
  meta:{version:'2.0',vehicle_id:'CP-HY-RD-190326',generated:'2026-08-16',parts:core.meta?.parts||parts.length,systems:core.meta?.systems||20,references:(core.refs||[]).length,faults:faults.length,tasks:tasks.length,sources:sources.length,orderable_references:core.meta?.orderable||0,status_counts:core.meta?.status||{},criticality_counts:core.meta?.crit||{},parts_by_system:core.meta?.bySystem||{},product:'CP Registo Mestre',public_mode:true},
  vehicle,parts,references:core.refs||[],faults,tasks,sources,rules,manuals:core.manuals||[],model:core.model||[],procedure:core.procedure||[],dataroom:core.dataroom||[]
};
})();