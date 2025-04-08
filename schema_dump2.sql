--
-- PostgreSQL database dump
--

-- Dumped from database version 14.15 (Ubuntu 14.15-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.15 (Ubuntu 14.15-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: delete_all_posts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_all_posts() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM draft_storage;
    DELETE FROM edit_draft;
    DELETE FROM published_posts;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    id integer NOT NULL,
    user_id integer,
    owns_space text NOT NULL
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: draft_storage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.draft_storage (
    id integer NOT NULL,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    edited_at timestamp without time zone,
    is_active boolean DEFAULT true
);


--
-- Name: draft_storage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.draft_storage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: draft_storage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.draft_storage_id_seq OWNED BY public.draft_storage.id;


--
-- Name: edit_draft; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.edit_draft (
    id integer NOT NULL,
    content text NOT NULL,
    edited_at timestamp without time zone DEFAULT now(),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: edit_draft_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.edit_draft_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: edit_draft_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.edit_draft_id_seq OWNED BY public.edit_draft.id;


--
-- Name: interests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.interests (
    id integer NOT NULL,
    user_id integer NOT NULL,
    interested_in integer NOT NULL
);


--
-- Name: interests2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.interests2 (
    id integer NOT NULL,
    user_id integer NOT NULL,
    interested_in integer NOT NULL
);


--
-- Name: interests2_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.interests2_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interests2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.interests2_id_seq OWNED BY public.interests2.id;


--
-- Name: interests3; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.interests3 (
    id integer NOT NULL,
    user_id integer NOT NULL,
    interested_in integer NOT NULL
);


--
-- Name: interests3_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.interests3_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interests3_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.interests3_id_seq OWNED BY public.interests3.id;


--
-- Name: interests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.interests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.interests_id_seq OWNED BY public.interests.id;


--
-- Name: movies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.movies (
    movieid integer NOT NULL,
    title text,
    genres text
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    space text,
    user_with_access integer
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: permissions_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions_log (
    id integer NOT NULL,
    admin_user integer,
    granted_user integer,
    space text,
    "timestamp" timestamp without time zone DEFAULT now()
);


--
-- Name: permissions_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_log_id_seq OWNED BY public.permissions_log.id;


--
-- Name: published_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.published_posts (
    id integer NOT NULL,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    edited_at timestamp without time zone,
    is_active boolean DEFAULT true
);


--
-- Name: published_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.published_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: published_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.published_posts_id_seq OWNED BY public.published_posts.id;


--
-- Name: ratings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ratings (
    userid integer NOT NULL,
    movieid integer NOT NULL,
    rating numeric(2,1),
    "timestamp" bigint
);


--
-- Name: rejections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rejections (
    id integer NOT NULL,
    user_id integer NOT NULL,
    rejected_id integer NOT NULL
);


--
-- Name: rejections2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rejections2 (
    id integer NOT NULL,
    user_id integer NOT NULL,
    rejected_id integer NOT NULL
);


--
-- Name: rejections2_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rejections2_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rejections2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rejections2_id_seq OWNED BY public.rejections2.id;


--
-- Name: rejections3; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rejections3 (
    id integer NOT NULL,
    user_id integer NOT NULL,
    rejected_id integer NOT NULL
);


--
-- Name: rejections3_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rejections3_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rejections3_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rejections3_id_seq OWNED BY public.rejections3.id;


--
-- Name: rejections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rejections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rejections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rejections_id_seq OWNED BY public.rejections.id;


--
-- Name: spaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spaces (
    id integer NOT NULL,
    space_name text NOT NULL
);


--
-- Name: spaces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spaces_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spaces_id_seq OWNED BY public.spaces.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL
);


--
-- Name: users2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users2 (
    id integer NOT NULL,
    username character varying(50) NOT NULL
);


--
-- Name: users2_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users2_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users2_id_seq OWNED BY public.users2.id;


--
-- Name: users3; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users3 (
    id integer NOT NULL,
    username character varying(50) NOT NULL
);


--
-- Name: users3_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users3_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users3_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users3_id_seq OWNED BY public.users3.id;


--
-- Name: users_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_access (
    id integer NOT NULL,
    username text NOT NULL
);


--
-- Name: users_access_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_access_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_access_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_access_id_seq OWNED BY public.users_access.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: draft_storage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.draft_storage ALTER COLUMN id SET DEFAULT nextval('public.draft_storage_id_seq'::regclass);


--
-- Name: edit_draft id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_draft ALTER COLUMN id SET DEFAULT nextval('public.edit_draft_id_seq'::regclass);


--
-- Name: interests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests ALTER COLUMN id SET DEFAULT nextval('public.interests_id_seq'::regclass);


--
-- Name: interests2 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests2 ALTER COLUMN id SET DEFAULT nextval('public.interests2_id_seq'::regclass);


--
-- Name: interests3 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests3 ALTER COLUMN id SET DEFAULT nextval('public.interests3_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: permissions_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions_log ALTER COLUMN id SET DEFAULT nextval('public.permissions_log_id_seq'::regclass);


--
-- Name: published_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.published_posts ALTER COLUMN id SET DEFAULT nextval('public.published_posts_id_seq'::regclass);


--
-- Name: rejections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections ALTER COLUMN id SET DEFAULT nextval('public.rejections_id_seq'::regclass);


--
-- Name: rejections2 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections2 ALTER COLUMN id SET DEFAULT nextval('public.rejections2_id_seq'::regclass);


--
-- Name: rejections3 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections3 ALTER COLUMN id SET DEFAULT nextval('public.rejections3_id_seq'::regclass);


--
-- Name: spaces id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces ALTER COLUMN id SET DEFAULT nextval('public.spaces_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users2 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users2 ALTER COLUMN id SET DEFAULT nextval('public.users2_id_seq'::regclass);


--
-- Name: users3 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users3 ALTER COLUMN id SET DEFAULT nextval('public.users3_id_seq'::regclass);


--
-- Name: users_access id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_access ALTER COLUMN id SET DEFAULT nextval('public.users_access_id_seq'::regclass);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: draft_storage draft_storage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.draft_storage
    ADD CONSTRAINT draft_storage_pkey PRIMARY KEY (id);


--
-- Name: edit_draft edit_draft_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_draft
    ADD CONSTRAINT edit_draft_pkey PRIMARY KEY (id);


--
-- Name: interests2 interests2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests2
    ADD CONSTRAINT interests2_pkey PRIMARY KEY (id);


--
-- Name: interests3 interests3_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests3
    ADD CONSTRAINT interests3_pkey PRIMARY KEY (id);


--
-- Name: interests interests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests
    ADD CONSTRAINT interests_pkey PRIMARY KEY (id);


--
-- Name: movies movies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (movieid);


--
-- Name: permissions_log permissions_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions_log
    ADD CONSTRAINT permissions_log_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: published_posts published_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.published_posts
    ADD CONSTRAINT published_posts_pkey PRIMARY KEY (id);


--
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (userid, movieid);


--
-- Name: rejections2 rejections2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections2
    ADD CONSTRAINT rejections2_pkey PRIMARY KEY (id);


--
-- Name: rejections3 rejections3_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections3
    ADD CONSTRAINT rejections3_pkey PRIMARY KEY (id);


--
-- Name: rejections rejections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections
    ADD CONSTRAINT rejections_pkey PRIMARY KEY (id);


--
-- Name: spaces spaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT spaces_pkey PRIMARY KEY (id);


--
-- Name: spaces spaces_space_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT spaces_space_name_key UNIQUE (space_name);


--
-- Name: interests unique_interest; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests
    ADD CONSTRAINT unique_interest UNIQUE (user_id, interested_in);


--
-- Name: interests2 unique_interest2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests2
    ADD CONSTRAINT unique_interest2 UNIQUE (user_id, interested_in);


--
-- Name: interests3 unique_interest3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests3
    ADD CONSTRAINT unique_interest3 UNIQUE (user_id, interested_in);


--
-- Name: rejections unique_rejection; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections
    ADD CONSTRAINT unique_rejection UNIQUE (user_id, rejected_id);


--
-- Name: rejections2 unique_rejection2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections2
    ADD CONSTRAINT unique_rejection2 UNIQUE (user_id, rejected_id);


--
-- Name: rejections3 unique_rejection3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections3
    ADD CONSTRAINT unique_rejection3 UNIQUE (user_id, rejected_id);


--
-- Name: users2 users2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users2
    ADD CONSTRAINT users2_pkey PRIMARY KEY (id);


--
-- Name: users2 users2_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users2
    ADD CONSTRAINT users2_username_key UNIQUE (username);


--
-- Name: users3 users3_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users3
    ADD CONSTRAINT users3_pkey PRIMARY KEY (id);


--
-- Name: users3 users3_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users3
    ADD CONSTRAINT users3_username_key UNIQUE (username);


--
-- Name: users_access users_access_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_access
    ADD CONSTRAINT users_access_pkey PRIMARY KEY (id);


--
-- Name: users_access users_access_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_access
    ADD CONSTRAINT users_access_username_key UNIQUE (username);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: single_active_edit; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX single_active_edit ON public.edit_draft USING btree (is_active) WHERE (is_active = true);


--
-- Name: admins admins_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users_access(id) ON DELETE CASCADE;


--
-- Name: interests2 interests2_interested_in_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests2
    ADD CONSTRAINT interests2_interested_in_fkey FOREIGN KEY (interested_in) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: interests2 interests2_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests2
    ADD CONSTRAINT interests2_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: interests3 interests3_interested_in_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests3
    ADD CONSTRAINT interests3_interested_in_fkey FOREIGN KEY (interested_in) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: interests3 interests3_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests3
    ADD CONSTRAINT interests3_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: interests interests_interested_in_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests
    ADD CONSTRAINT interests_interested_in_fkey FOREIGN KEY (interested_in) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: interests interests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interests
    ADD CONSTRAINT interests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: permissions_log permissions_log_admin_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions_log
    ADD CONSTRAINT permissions_log_admin_user_fkey FOREIGN KEY (admin_user) REFERENCES public.users_access(id) ON DELETE CASCADE;


--
-- Name: permissions_log permissions_log_granted_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions_log
    ADD CONSTRAINT permissions_log_granted_user_fkey FOREIGN KEY (granted_user) REFERENCES public.users_access(id) ON DELETE CASCADE;


--
-- Name: permissions_log permissions_log_space_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions_log
    ADD CONSTRAINT permissions_log_space_fkey FOREIGN KEY (space) REFERENCES public.spaces(space_name) ON DELETE CASCADE;


--
-- Name: permissions permissions_space_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_space_fkey FOREIGN KEY (space) REFERENCES public.spaces(space_name) ON DELETE CASCADE;


--
-- Name: permissions permissions_user_with_access_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_user_with_access_fkey FOREIGN KEY (user_with_access) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: ratings ratings_movieid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.movies(movieid);


--
-- Name: rejections2 rejections2_rejected_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections2
    ADD CONSTRAINT rejections2_rejected_id_fkey FOREIGN KEY (rejected_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rejections2 rejections2_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections2
    ADD CONSTRAINT rejections2_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rejections3 rejections3_rejected_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections3
    ADD CONSTRAINT rejections3_rejected_id_fkey FOREIGN KEY (rejected_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rejections3 rejections3_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections3
    ADD CONSTRAINT rejections3_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rejections rejections_rejected_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections
    ADD CONSTRAINT rejections_rejected_id_fkey FOREIGN KEY (rejected_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rejections rejections_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections
    ADD CONSTRAINT rejections_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

