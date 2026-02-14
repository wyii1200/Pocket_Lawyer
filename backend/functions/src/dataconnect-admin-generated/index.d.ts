import { ConnectorConfig, DataConnect, OperationOptions, ExecuteOperationResponse } from 'firebase-admin/data-connect';

export const connectorConfig: ConnectorConfig;

export type TimestampString = string;
export type UUIDString = string;
export type Int64String = string;
export type DateString = string;


export interface DocumentTemplate_Key {
  id: UUIDString;
  __typename?: 'DocumentTemplate_Key';
}

export interface GetPublicLegalArticlesData {
  legalArticles: ({
    id: UUIDString;
    title: string;
    content: string;
    sourceUrl?: string | null;
    legalTopic?: {
      name: string;
    };
  } & LegalArticle_Key)[];
}

export interface LegalArticle_Key {
  id: UUIDString;
  __typename?: 'LegalArticle_Key';
}

export interface LegalTopic_Key {
  id: UUIDString;
  __typename?: 'LegalTopic_Key';
}

export interface UserDocument_Key {
  id: UUIDString;
  __typename?: 'UserDocument_Key';
}

export interface User_Key {
  id: UUIDString;
  __typename?: 'User_Key';
}

/** Generated Node Admin SDK operation action function for the 'GetPublicLegalArticles' Query. Allow users to execute without passing in DataConnect. */
export function getPublicLegalArticles(dc: DataConnect, options?: OperationOptions): Promise<ExecuteOperationResponse<GetPublicLegalArticlesData>>;
/** Generated Node Admin SDK operation action function for the 'GetPublicLegalArticles' Query. Allow users to pass in custom DataConnect instances. */
export function getPublicLegalArticles(options?: OperationOptions): Promise<ExecuteOperationResponse<GetPublicLegalArticlesData>>;

