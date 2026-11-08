import type { Direction } from './lib/solidarity';

export type NeedType = 'servicio' | 'producto' | 'prestamo' | 'ayuda';
export type NeedStatus = 'abierta' | 'en_curso' | 'cerrada' | 'cancelada';
export type ProposalStatus = 'enviada' | 'aceptada' | 'rechazada' | 'retirada';
export type MessageStatus = 'pendiente' | 'enviado' | 'fallido';
export type EmergencyKind = 'sismo' | 'incendio' | 'medico' | 'persona_mayor' | 'seguridad' | 'violencia';
export type Tab = 'inicio' | 'vecinos' | 'mensajes' | 'emergencia' | 'perfil';

export interface User {
  id: string;
  name: string;
  zone: string;
  lat: number | null;
  lng: number | null;
  level: string;
  color: string;
}

export interface Need {
  id: string;
  authorId: string;
  authorName: string;
  authorColor: string;
  type: NeedType;
  title: string;
  description: string;
  category: string;
  zone: string;
  latPublic: number | null;
  lngPublic: number | null;
  status: NeedStatus;
  isEmergency: boolean;
  createdAt: string;
  recommendations: number;
  distanceKm: number | null;
}

export interface Proposal {
  id: string;
  needId: string;
  providerId: string;
  providerName: string;
  priceCents: number;
  message: string;
  eta: string;
  status: ProposalStatus;
  createdAt: string;
}

export interface Conversation {
  id: string;
  needId: string;
  needTitle: string;
  otherId: string;
  otherName: string;
  otherColor: string;
  roomId: string | null;
  priceCents: number;
  status: string;
  createdAt: string;
  lastBody: string | null;
  lastAt: string | null;
  pending: number;
}

export interface Message {
  id: string;
  interactionId: string;
  roomId: string;
  senderId: string;
  body: string;
  txnId: string;
  status: MessageStatus;
  createdAt: string;
  mine: boolean;
  system: boolean;
}

export interface Provider {
  id: string;
  name: string;
  zone: string;
  color: string;
  level: string;
  category: string | null;
  latest: string | null;
  recommendations: number;
  recommendedByMe: boolean;
  distanceKm: number | null;
}

export interface Emergency {
  id: string;
  authorId: string;
  kind: EmergencyKind;
  description: string;
  zone: string;
  latPublic: number | null;
  lngPublic: number | null;
  status: 'activa' | 'atendida' | 'cerrada';
  institutionCalled: boolean;
  createdAt: string;
}

/** Alerta de otro vecino tal como se ve en el muro (solo zona aproximada, nunca la ubicación exacta). */
export interface EmergencyWallItem extends Emergency {
  authorName: string;
  authorColor: string;
  distanceKm: number | null;
  /** En alertas normales: quienes dijeron "puedo ayudar". En avisos de seguridad: quienes lo confirman. */
  helpers: { id: string; name: string; zone: string }[];
  /** Verdadero si yo dije "puedo ayudar" (o, en un aviso de seguridad, "yo también lo vi"). */
  iOffered: boolean;
  /** Solo avisos de seguridad: vecinos que lo marcaron como "no es real o ya pasó". */
  disputes: number;
  iDisputed: boolean;
}

/** Oficios que un vecino puede ofrecer. "Otros" cubre lo que no esté en la lista. */
export const TRADES = [
  'Gasfitería',
  'Electricidad',
  'Cerrajería',
  'Carpintería',
  'Enfermería',
  'Transporte',
  'Agua y gas',
  'Paseo de mascotas',
  'Clases y refuerzo escolar',
  'Cuidado de niños y adultos mayores',
  'Costura y arreglos',
  'Limpieza y jardinería',
  'Reparación de electrodomésticos',
  'Cocina y repostería',
  'Otros',
] as const;

export interface ServiceOffer {
  id: string;
  providerId: string;
  trade: string;
  description: string;
  urgent: boolean;
  availableNow: boolean;
  schedule: string;
}

/** Vecino del directorio: sus datos de confianza más todo lo que ofrece (urgente o no). */
export interface DirectoryEntry extends Provider {
  offers: ServiceOffer[];
}

/** Servicio de urgencia de otro vecino (con costo: el precio se propone al pedirlo). */
export interface UrgentService extends ServiceOffer {
  providerName: string;
  providerColor: string;
  level: string;
  recommendations: number;
  distanceKm: number | null;
}

export interface UrgentRequest {
  need: Need;
  /** Verdadero si el usuario ofrece ese oficio como servicio de urgencia. */
  matchesMe: boolean;
  proposals: number;
}

/** Publicación de recurso crítico (agua, alimentos, abrigo…) que alguien necesita u ofrece en una emergencia. */
export interface ResourcePost {
  need: Need;
  direction: Direction;
  resource: string;
  proposals: number;
  mine: boolean;
  /** Cuántas publicaciones de otros vecinos, del mismo recurso y en sentido contrario, encajan con esta. */
  matches: number;
}

export interface Stats {
  helps: number;
  people: number;
  avgStars: number | null;
  recommendations: number;
  pending: number;
}

export const NEED_LABEL: Record<NeedType, string> = {
  servicio: 'Servicio',
  producto: 'Producto',
  prestamo: 'Préstamo',
  ayuda: 'Ayuda',
};

export const EMERGENCY_LABEL: Record<EmergencyKind, string> = {
  sismo: 'Sismo',
  incendio: 'Incendio',
  medico: 'Emergencia médica',
  persona_mayor: 'Persona mayor en riesgo',
  seguridad: 'Aviso de seguridad',
  violencia: 'Violencia (privado)',
};
